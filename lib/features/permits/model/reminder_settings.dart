import 'package:nad_parseta/domain/model/json.dart';

class ReminderSettings {
  const ReminderSettings({
    this.sevenDays = true,
    this.oneDay = true,
    this.expiryDay = false,
    this.hour = 9,
  });

  final bool sevenDays;
  final bool oneDay;
  final bool expiryDay;
  final int hour;

  Json toJson() => {
    'sevenDays': sevenDays,
    'oneDay': oneDay,
    'expiryDay': expiryDay,
    'hour': hour,
  };

  factory ReminderSettings.fromJson(Json j) => ReminderSettings(
    sevenDays: j['sevenDays'] ?? true,
    oneDay: j['oneDay'] ?? true,
    expiryDay: j['expiryDay'] ?? false,
    hour: j['hour'] ?? 9,
  );
}
