import 'package:nad_parseta/domain/model/json.dart';

enum SyncKind { session, catchEntry, attachment }

class SyncOperation {
  SyncOperation({
    required this.id,
    required this.entityId,
    required this.kind,
    required this.revision,
    required this.createdAt,
    Json payload = const {},
  }) : payload = Map.unmodifiable(payload);
  final String id;
  final String entityId;
  final SyncKind kind;
  final int revision;
  final DateTime createdAt;
  final Json payload;
  bool get isAccounting => kind != SyncKind.attachment;
  Json toJson() => {
    'id': id,
    'entityId': entityId,
    'kind': kind.name,
    'revision': revision,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'payload': payload,
  };
  factory SyncOperation.fromJson(Json j) => SyncOperation(
    id: j['id'],
    entityId: j['entityId'],
    kind: SyncKind.values.byName(j['kind']),
    revision: j['revision'],
    createdAt: DateTime.parse(j['createdAt']),
    payload: Map<String, dynamic>.from(j['payload'] ?? {}),
  );
}
