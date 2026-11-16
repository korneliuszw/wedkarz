import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';
import '../features/auth/service/authentication_service.dart';
import 'angler_http_client.dart';
import 'catalog.dart';

export '../features/fishing/repository/catch_history.dart'
    show mergeCatchHistory;
export 'angler_http_client.dart' show apiUrl;

class AnglerApi implements AuthenticationService {
  AnglerApi(Dio client, SharedPreferences preferences, {String url = apiUrl})
    : _http = AnglerHttpClient(client, preferences, url: url);

  final AnglerHttpClient _http;

  Future<Json> request(
    String method,
    String path, {
    AuthSession? session,
    Json? body,
    Map<String, String>? query,
  }) => _http.request(method, path, session: session, body: body, query: query);

  AuthSession _session(Json response, {DateTime? refreshExpiresAt}) {
    final user = response['user'] as Json;
    final number = user['accountNumber'].toString();
    final name = [
      user['firstName'],
      user['lastName'],
    ].whereType<String>().where((part) => part.trim().isNotEmpty).join(' ');
    final now = DateTime.now();
    return AuthSession(
      user: AppUser(
        id: user['id'].toString(),
        displayName: name.isEmpty ? number : name,
        email: number,
        role: UserRole.angler,
        registerEnabled: user['registerEnabled'] == true,
      ),
      accessToken: response['accessToken'] as String,
      refreshToken: response['refreshToken'] as String,
      accessExpiresAt: now.add(Duration(seconds: response['expiresIn'] as int)),
      refreshExpiresAt: refreshExpiresAt ?? now.add(const Duration(days: 7)),
    );
  }

  @override
  Future<AuthSession> signIn(String account, String password) async {
    final number = int.tryParse(account.trim());
    if (number == null || number < 1 || number > 4294967295) {
      throw const AuthFailure();
    }
    return _session(
      await request(
        'POST',
        'auth/sessions',
        body: {'accountNumber': number, 'password': password},
      ),
    );
  }

  @override
  Future<AuthSession> refresh(AuthSession session) async => _session(
    await request(
      'POST',
      'auth/refresh',
      body: {'refreshToken': session.refreshToken},
    ),
    refreshExpiresAt: session.refreshExpiresAt,
  );

  Future<void> acceptRegister(AuthSession session) async {
    await request(
      'PUT',
      'me/register-consent',
      session: session,
      body: {'accepted': true},
    );
  }

  Future<List<FishSpecies>> fetchSpecies(AuthSession session) async {
    final response = await request('GET', 'species', session: session);
    return readList(response, 'items', (row) {
      final name = row['name'] as String;
      return FishSpecies(
        id: row['id'].toString(),
        name: name,
        asset:
            speciesIllustrations
                .where(
                  (fish) =>
                      fish.name.toLowerCase() == name.trim().toLowerCase(),
                )
                .firstOrNull
                ?.asset ??
            '',
      );
    });
  }

  Future<DateTime> sendCatch(
    SyncOperation operation,
    AuthSession session,
  ) async {
    final entry = CatchEntry.fromJson(operation.payload);
    final response = await request(
      'POST',
      'catches',
      session: session,
      body: {
        'clientId': operation.entityId,
        'sessionId': entry.sessionId,
        'caughtAt': entry.caughtAt.toUtc().toIso8601String(),
        'place': placeById(entry.placeId).label,
        'speciesId': int.parse(entry.speciesId),
        'lengthMm': entry.lengthMm,
        'weightGrams': entry.weightGrams,
        'fate': entry.fate.name,
      },
    );
    if (response['clientId'] != operation.entityId) {
      throw const DomainFailure(FailureCode.syncFailed);
    }
    return DateTime.parse(response['receivedAt'] as String);
  }

  Json catchPayload(CatchEntry entry, String registerLocation) => {
    'clientId': entry.id,
    'caughtAt': entry.caughtAt.toUtc().toIso8601String(),
    'place': registerLocation,
    'speciesId': int.parse(entry.speciesId),
    'lengthMm': entry.lengthMm,
    'weightGrams': entry.weightGrams,
    'fate': entry.fate.name,
  };

  Future<({DateTime at, String? signed})> submitFishingSession(
    SyncOperation operation,
    AuthSession session,
  ) async {
    final response = await request(
      'POST',
      'fishing-sessions',
      session: session,
      body: operation.payload,
    );
    if (response['id'] != operation.entityId) {
      throw const DomainFailure(FailureCode.syncFailed);
    }
    return (
      at: DateTime.parse(response['receivedAt'] as String),
      signed: response['signedReceipt'] as String?,
    );
  }

  Future<List<Permit>> permits(AuthSession session) async {
    final rows = await _list('permits', session);
    return rows.map((row) {
      final end = DateTime.parse(row['endsOn'] as String);
      return Permit(
        id: row['id'].toString(),
        ownerId: session.user.id,
        number: row['id'].toString(),
        areaName: row['area'] as String,
        validFrom: DateTime.parse(row['startsOn'] as String),
        validUntil: DateTime(end.year, end.month, end.day + 1),
      );
    }).toList();
  }

  Future<DateTime> sendCatchPhoto(
    CatchAttachment photo,
    AuthSession session,
  ) async {
    final response = await request(
      'PUT',
      'catches/${photo.catchId}/photo',
      session: session,
      body: {'base64': photo.base64Bytes},
    );
    if (response['clientId'] != photo.catchId) {
      throw const DomainFailure(FailureCode.syncFailed);
    }
    return DateTime.parse(response['receivedAt'] as String);
  }

  Future<List<Json>> catchHistory(AuthSession session) =>
      _list('catches', session);

  Future<List<Json>> _list(String resource, AuthSession session) async {
    final items = <Json>[];
    int? before;
    do {
      final response = await request(
        'GET',
        resource,
        session: session,
        query: {'limit': '100', if (before != null) 'before': '$before'},
      );
      items.addAll(readList(response, 'items', (row) => row));
      final next = response['nextBefore'] as int?;
      if (next != null && before != null && next >= before) {
        throw const DomainFailure(FailureCode.syncFailed);
      }
      before = next;
    } while (before != null);
    return items;
  }
}
