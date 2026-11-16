class Permit {
  const Permit({
    required this.id,
    required this.ownerId,
    required this.number,
    required this.areaName,
    required this.validFrom,
    required this.validUntil,
  });
  final String id;
  final String ownerId;
  final String number;
  final String areaName;
  final DateTime validFrom;
  final DateTime validUntil;
  bool isValidAt(DateTime now) =>
      !now.isBefore(validFrom) && now.isBefore(validUntil);
}
