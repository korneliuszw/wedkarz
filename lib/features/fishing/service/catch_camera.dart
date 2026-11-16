import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../model/catch_attachment.dart';

final catchCameraProvider = Provider<Future<String?> Function()?>((ref) {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
  return takeCatchPhoto;
});

Future<String?> takeCatchPhoto() async {
  final image = await ImagePicker().pickImage(
    source: ImageSource.camera,
    maxWidth: 800,
    maxHeight: 800,
    imageQuality: 65,
    requestFullMetadata: false,
  );
  if (image == null) return null;
  if (await image.length() > maxCatchPhotoBytes) {
    throw const FormatException('Catch photo exceeds the size limit');
  }
  final bytes = await image.readAsBytes();
  if (!isCatchPhotoJpeg(bytes)) throw StateError('Camera did not return JPEG');
  return base64Encode(bytes);
}
