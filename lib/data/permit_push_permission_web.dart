import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<bool> requestBrowserPushPermission() async =>
    (await web.Notification.requestPermission().toDart).toDart == 'granted';
