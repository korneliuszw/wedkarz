import 'package:nad_parseta/domain/model/json.dart';

enum UserRole { angler, ranger }

class AppUser {
  const AppUser({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    this.registerEnabled = true,
  });
  final String id;
  final String displayName;
  final String email;
  final UserRole role;
  final bool registerEnabled;
  Json toJson() => {
    'id': id,
    'displayName': displayName,
    'email': email,
    'role': role.name,
    'registerEnabled': registerEnabled,
  };
  factory AppUser.fromJson(Json j) => AppUser(
    id: j['id'],
    displayName: j['displayName'],
    email: j['email'],
    role: UserRole.values.byName(j['role']),
    registerEnabled: j['registerEnabled'] as bool? ?? true,
  );
}

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
    required this.refreshExpiresAt,
  });
  final AppUser user;
  final String accessToken;
  final String refreshToken;
  final DateTime accessExpiresAt;
  final DateTime refreshExpiresAt;
  bool canRefreshAt(DateTime now) => now.isBefore(refreshExpiresAt);
  bool needsRefreshAt(DateTime now) =>
      !now.add(const Duration(seconds: 30)).isBefore(accessExpiresAt);
  AuthSession withRegisterEnabled() => AuthSession(
    user: AppUser(
      id: user.id,
      displayName: user.displayName,
      email: user.email,
      role: user.role,
      registerEnabled: true,
    ),
    accessToken: accessToken,
    refreshToken: refreshToken,
    accessExpiresAt: accessExpiresAt,
    refreshExpiresAt: refreshExpiresAt,
  );
  Json toJson() => {
    'user': user.toJson(),
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'accessExpiresAt': accessExpiresAt.toUtc().toIso8601String(),
    'refreshExpiresAt': refreshExpiresAt.toUtc().toIso8601String(),
  };
  factory AuthSession.fromJson(Json j) => AuthSession(
    user: AppUser.fromJson(j['user']),
    accessToken: j['accessToken'],
    refreshToken: j['refreshToken'],
    accessExpiresAt: DateTime.parse(j['accessExpiresAt']),
    refreshExpiresAt: DateTime.parse(j['refreshExpiresAt']),
  );
}
