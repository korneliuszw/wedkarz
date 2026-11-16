import 'package:nad_parseta/domain/model/json.dart';

class FishingPlace {
  const FishingPlace({
    required this.id,
    required this.waterName,
    required this.sectionName,
    this.areaId,
    this.coordinates,
    this.customName,
  });
  final String id;
  final String waterName;
  final String sectionName;
  final int? areaId;
  final String? coordinates;
  final String? customName;
  String get label =>
      customName ??
      (coordinates == null
          ? (sectionName.isEmpty ? waterName : '$waterName · $sectionName')
          : '$waterName · $coordinates');
  String get registerLocation => coordinates ?? label;

  Json toJson() => {
    'id': id,
    'waterName': waterName,
    'sectionName': sectionName,
    'areaId': areaId,
    'coordinates': coordinates,
    'customName': customName,
  };

  factory FishingPlace.fromJson(Json j) => FishingPlace(
    id: j['id'] as String,
    waterName: j['waterName'] as String,
    sectionName: j['sectionName'] as String,
    areaId: j['areaId'] as int?,
    coordinates: j['coordinates'] as String?,
    customName: j['customName'] as String?,
  );
}
