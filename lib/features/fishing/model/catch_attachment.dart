import 'package:nad_parseta/domain/model/json.dart';

const maxCatchPhotoBytes = 256 * 1024;

bool isCatchPhotoJpeg(List<int> bytes) =>
    bytes.length >= 5 &&
    bytes.length <= maxCatchPhotoBytes &&
    bytes[0] == 0xff &&
    bytes[1] == 0xd8 &&
    bytes[2] == 0xff &&
    bytes[bytes.length - 2] == 0xff &&
    bytes.last == 0xd9;

class CatchAttachment {
  const CatchAttachment({
    required this.id,
    required this.catchId,
    required this.base64Bytes,
    required this.createdAt,
    this.syncedAt,
  });
  final String id;
  final String catchId;
  final String base64Bytes;
  final DateTime createdAt;
  final DateTime? syncedAt;
  CatchAttachment acknowledge(DateTime at) => CatchAttachment(
    id: id,
    catchId: catchId,
    base64Bytes: base64Bytes,
    createdAt: createdAt,
    syncedAt: at,
  );
  Json toJson() => {
    'id': id,
    'catchId': catchId,
    'base64Bytes': base64Bytes,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'syncedAt': syncedAt?.toUtc().toIso8601String(),
  };
  factory CatchAttachment.fromJson(Json j) => CatchAttachment(
    id: j['id'],
    catchId: j['catchId'],
    base64Bytes: j['base64Bytes'],
    createdAt: DateTime.parse(j['createdAt']),
    syncedAt: optionalDate(j['syncedAt']),
  );
}
