import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:inspection_protocol/inspection_protocol.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';
import 'angler_api.dart';
import 'catalog.dart';
import 'inspection_key.dart';

class OfflineInspection {
  OfflineInspection(this.api, this.preferences);
  final AnglerApi api;
  final SharedPreferences preferences;
  static const root = String.fromEnvironment('INSPECTION_ROOT_PUBLIC_KEY');
  String _storageKey(String owner) => 'inspection:$apiUrl:$owner';
  InspectionKey _key(String owner) => InspectionKey(_storageKey(owner));

  final _enrollments = <String, Future<void>>{};

  Future<void> ensureProvisioned(AuthSession session) async {
    if (root.isEmpty) return;
    try {
      final cached = preferences.getString(_storageKey(session.user.id));
      if (cached != null) {
        final claims = _verify(jsonDecode(cached) as Json);
        final refreshAt = (claims['issuedAt'] as int) + 3600;
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (now < refreshAt && now + 600 < (claims['exp'] as int)) return;
      }
    } catch (_) {
      // Replace an unusable credential while connectivity is available.
    }
    await provision(session);
  }

  Future<void> provision(AuthSession session) => _enrollments.putIfAbsent(
    session.user.id,
    () => _enroll(
      session,
    ).whenComplete(() => _enrollments.remove(session.user.id)),
  );

  Future<void> _enroll(AuthSession session) async {
    if (root.isEmpty) throw const DomainFailure(FailureCode.invalidCode);
    final owner = session.user.id;
    final key = _key(owner);
    final public = await key.publicKey();
    final response = await api.request(
      'POST',
      'inspection/challenge',
      session: session,
    );
    final challenge = response['challenge'] as String;
    final proof = await key.sign(
      Uint8List.fromList(utf8.encode('parseta-enrollment-v1:$challenge')),
    );
    final credential = await api.request(
      'POST',
      'inspection/credential',
      session: session,
      body: {
        'challenge': challenge,
        'publicKey': compact64(public),
        'proof': compact64(proof),
      },
    );
    final claims = _verify(credential);
    if (claims['owner'].toString() != owner ||
        compact64(inspectionByteField(claims['key'])) != compact64(public)) {
      throw const DomainFailure(FailureCode.invalidCode);
    }
    if (!await preferences.setString(
      _storageKey(owner),
      jsonEncode(credential),
    )) {
      throw const DomainFailure(FailureCode.storage);
    }
  }

  Map<String, dynamic> _verify(Json data) {
    final manifest = SignedInspection.parse(
      read64(data['manifest'] as String),
    ).verify(read64(root), 'parseta-manifest');
    final credential = SignedInspection.parse(
      read64(data['credential'] as String),
    ).verify(inspectionByteField(manifest['key']), 'parseta-permit');
    if ((manifest['revoked'] as List).contains(credential['serial'])) {
      throw const DomainFailure(FailureCode.invalidCode);
    }
    return credential;
  }

  Future<List<String>> present(
    String owner,
    AnglerSnapshot snapshot,
    List<FishSpecies> species,
  ) async {
    final cached = preferences.getString(_storageKey(owner));
    if (cached == null) throw const DomainFailure(FailureCode.invalidCode);
    final data = jsonDecode(cached) as Json;
    final credential = _verify(data);
    final key = _key(owner);
    final rawKey = inspectionByteField(credential['key']);
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if ((credential['exp'] as int) <= now) {
      throw const DomainFailure(FailureCode.invalidCode);
    }
    if (credential['owner'].toString() != owner ||
        compact64(await key.publicKey()) != compact64(rawKey)) {
      throw const DomainFailure(FailureCode.invalidCode);
    }
    final random = Random.secure();
    final active = snapshot.activeSession;
    final encoded = await SignedInspection.create(
      {
        'type': 'parseta-snapshot',
        'v': 1,
        'manifest': read64(data['manifest'] as String),
        'credential': read64(data['credential'] as String),
        'issuedAt': now,
        'exp': now + 120,
        'presentation': Uint8List.fromList(
          List.generate(16, (_) => random.nextInt(256)),
        ),
        'sessionId': active?.id,
        if (active?.signedReceipt case final receipt?)
          'receipt': read64(receipt),
        'catches': [
          for (final fish in snapshot.currentSessionCatches)
            [
              fish.id,
              speciesById(fish.speciesId, species).name,
              placeById(fish.placeId, snapshot.places).registerLocation,
              fish.caughtAt.millisecondsSinceEpoch,
              fish.quantity,
              fish.lengthMm,
              fish.weightGrams,
              fish.fate.name,
              int.parse(fish.speciesId),
            ],
        ],
      },
      rawKey,
      key.sign,
    );
    return inspectionFrames('$inspectionPrefix${compact64(encoded)}');
  }
}
