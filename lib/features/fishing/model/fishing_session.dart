import 'package:nad_parseta/domain/model/json.dart';
import 'package:nad_parseta/domain/model/failure.dart';

class FishingSession {
  FishingSession({
    required this.id,
    required this.ownerId,
    required this.startedAt,
    required List<String> placeIds,
    required this.currentPlaceId,
    this.endedAt,
    this.revision = 1,
    this.signedReceipt,
    this.submittedAt,
  }) : placeIds = List.unmodifiable(placeIds.toSet()) {
    if (!this.placeIds.contains(currentPlaceId)) {
      throw ArgumentError('currentPlaceId');
    }
  }
  final String id;
  final String ownerId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? signedReceipt;
  final DateTime? submittedAt;
  final List<String> placeIds;
  final String currentPlaceId;
  final int revision;
  bool get isActive => endedAt == null;
  FishingSession selectPlace(String placeId) {
    if (!isActive) throw const DomainFailure(FailureCode.closedSession);
    return FishingSession(
      id: id,
      ownerId: ownerId,
      startedAt: startedAt,
      placeIds: [...placeIds, if (!placeIds.contains(placeId)) placeId],
      currentPlaceId: placeId,
      revision: revision + 1,
    );
  }

  FishingSession end(DateTime at) => FishingSession(
    id: id,
    ownerId: ownerId,
    startedAt: startedAt,
    placeIds: placeIds,
    currentPlaceId: currentPlaceId,
    endedAt: at,
    revision: revision + 1,
  );
  FishingSession withReceipt(DateTime at, String? receipt) => FishingSession(
    id: id,
    ownerId: ownerId,
    startedAt: startedAt,
    endedAt: endedAt,
    placeIds: placeIds,
    currentPlaceId: currentPlaceId,
    revision: revision,
    signedReceipt: receipt,
    submittedAt: at,
  );
  Json toJson() => {
    'id': id,
    'ownerId': ownerId,
    'startedAt': startedAt.toUtc().toIso8601String(),
    'endedAt': endedAt?.toUtc().toIso8601String(),
    'signedReceipt': signedReceipt,
    'submittedAt': submittedAt?.toUtc().toIso8601String(),
    'placeIds': placeIds,
    'currentPlaceId': currentPlaceId,
    'revision': revision,
  };
  factory FishingSession.fromJson(Json j) => FishingSession(
    id: j['id'],
    ownerId: j['ownerId'],
    startedAt: DateTime.parse(j['startedAt']),
    endedAt: optionalDate(j['endedAt']),
    signedReceipt: j['signedReceipt'] as String?,
    submittedAt: optionalDate(j['submittedAt']),
    placeIds: List<String>.from(j['placeIds']),
    currentPlaceId: j['currentPlaceId'],
    revision: j['revision'],
  );
}
