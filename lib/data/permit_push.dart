import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../domain/models.dart';
import 'permit_push_permission.dart';

class PermitPush {
  static const _project = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _sender = String.fromEnvironment('FIREBASE_SENDER_ID');
  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _androidApp = String.fromEnvironment('FIREBASE_ANDROID_APP_ID');
  static const _webApp = String.fromEnvironment('FIREBASE_WEB_APP_ID');
  static const _vapid = String.fromEnvironment('FIREBASE_VAPID_KEY');

  static bool get configured =>
      _project.isNotEmpty &&
      _sender.isNotEmpty &&
      _apiKey.isNotEmpty &&
      (kIsWeb
          ? _webApp.isNotEmpty && _vapid.isNotEmpty
          : _androidApp.isNotEmpty);

  static Future<String?> registration({bool prompt = false}) async {
    if (!configured) return null;
    try {
      if (prompt && kIsWeb && !await requestBrowserPushPermission()) {
        return null;
      }
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: _apiKey,
            appId: kIsWeb ? _webApp : _androidApp,
            messagingSenderId: _sender,
            projectId: _project,
          ),
        );
      }
      final active = Firebase.app().options;
      if (active.projectId != _project ||
          active.messagingSenderId != _sender ||
          active.appId != (kIsWeb ? _webApp : _androidApp)) {
        throw const DomainFailure(FailureCode.pushUnavailable);
      }
      final messaging = FirebaseMessaging.instance;
      if (!await messaging.isSupported()) return null;
      final permission = prompt && !kIsWeb
          ? await messaging.requestPermission()
          : await messaging.getNotificationSettings();
      if (permission.authorizationStatus != AuthorizationStatus.authorized &&
          permission.authorizationStatus != AuthorizationStatus.provisional) {
        return null;
      }
      return messaging.getToken(vapidKey: kIsWeb ? _vapid : null);
    } catch (_) {
      if (prompt) throw const DomainFailure(FailureCode.pushUnavailable);
      return null;
    }
  }
}
