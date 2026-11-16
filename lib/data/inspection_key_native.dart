import 'package:flutter/services.dart';

class InspectionKey {
  const InspectionKey(this.alias);
  final String alias;
  static const _channel = MethodChannel('pl.parseta/inspection');
  Future<Uint8List> publicKey() async =>
      (await _channel.invokeMethod<Uint8List>('publicKey', {'alias': alias}))!;
  Future<Uint8List> sign(Uint8List data) async => (await _channel
      .invokeMethod<Uint8List>('sign', {'alias': alias, 'data': data}))!;
}
