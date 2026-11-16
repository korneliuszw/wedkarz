import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../domain/models.dart';

const apiUrl = String.fromEnvironment(
  'ANGLER_API_URL',
  defaultValue: String.fromEnvironment('API_URL'),
);

class AnglerHttpClient {
  AnglerHttpClient(
    this._client,
    SharedPreferences preferences, {
    String url = apiUrl,
  }) : _base = Uri.parse(url),
       _preferences = preferences {
    final loopback = [
      'localhost',
      '127.0.0.1',
      '10.0.2.2',
    ].contains(_base.host);
    if (_base.host.isEmpty ||
        _base.userInfo.isNotEmpty ||
        _base.hasQuery ||
        _base.hasFragment ||
        (_base.scheme != 'https' && !(_base.scheme == 'http' && loopback))) {
      throw ArgumentError(
        'API_URL must use HTTPS or a local development address',
      );
    }
  }

  final http.Client _client;
  final Uri _base;
  final SharedPreferences _preferences;

  Future<Json> request(
    String method,
    String path, {
    AuthSession? session,
    Json? body,
    Map<String, String>? query,
  }) async {
    const deviceKey = 'nad_parseta_api_device';
    var device = _preferences.getString(deviceKey);
    if (device == null) {
      device = const Uuid().v4();
      if (!await _preferences.setString(deviceKey, device)) {
        throw const DomainFailure(FailureCode.storage);
      }
    }
    final uri = _base.replace(
      path: '${_base.path.replaceFirst(RegExp(r'/$'), '')}/v1/$path',
      queryParameters: query,
    );
    final request = http.Request(method, uri)
      ..followRedirects = false
      ..headers.addAll({
        'accept': 'application/json',
        'x-device-id': device,
        if (kDebugMode && const bool.fromEnvironment('PINGGY_DEV_TUNNEL'))
          'x-pinggy-no-screen': '1',
        if (session != null) 'authorization': 'Bearer ${session.accessToken}',
        if (body != null) 'content-type': 'application/json',
      });
    if (body != null) request.body = jsonEncode(body);
    late final http.Response response;
    try {
      response = await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const DomainFailure(FailureCode.offline);
    } on http.ClientException {
      throw const DomainFailure(FailureCode.offline);
    }
    switch (response.statusCode) {
      case 204:
        return {};
      case 200:
      case 201:
        return jsonDecode(utf8.decode(response.bodyBytes)) as Json;
      case 401:
        throw AuthFailure(
          path == 'auth/sessions'
              ? FailureCode.invalidCredentials
              : FailureCode.expiredSession,
        );
      case 403:
        throw const AuthorizationFailure();
      case 422:
        throw const DomainFailure(FailureCode.invalidMeasurement);
      case 429:
        throw const DomainFailure(FailureCode.rateLimited);
      default:
        throw const DomainFailure(FailureCode.syncFailed);
    }
  }
}
