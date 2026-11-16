import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspection_protocol/inspection_protocol.dart';

void main() {
  final fixture =
      jsonDecode(
            File('test/fixtures/inspection_protocol.json').readAsStringSync(),
          )
          as Map<String, dynamic>;
  final now = DateTime.fromMillisecondsSinceEpoch(1794560000000);
  final root = read64(fixture['root'] as String);
  final code = fixture['code'] as String;

  test('verifies Bun COSE signatures and matches only the signed catch', () {
    final result = verifyInspection(code, root, now);
    expect(result.currentStatus, isTrue);
    expect(result.received, {'server-confirmed'});
  });

  test('rejects expired, tampered and revoked presentations', () {
    expect(
      () => verifyInspection(code, root, now.add(const Duration(minutes: 3))),
      throwsFormatException,
    );
    final altered = read64(code.substring(inspectionPrefix.length));
    altered[altered.length - 1] ^= 1;
    expect(
      () =>
          verifyInspection('$inspectionPrefix${compact64(altered)}', root, now),
      throwsFormatException,
    );
    expect(
      () => verifyInspection(
        code,
        root,
        now,
        cachedManifest: fixture['revocation'] as String,
      ),
      throwsFormatException,
    );
  });

  test('accepts duplicate and out-of-order QR frames', () {
    final frames = inspectionFrames(code);
    expect(frames.length, greaterThan(1));
    final reader = InspectionFrameReader();
    expect(reader.add(frames.last), isNull);
    expect(reader.add(frames.last), isNull);
    String? full;
    for (final frame in frames.take(frames.length - 1)) {
      full = reader.add(frame);
    }
    expect(full, code);
  });
}
