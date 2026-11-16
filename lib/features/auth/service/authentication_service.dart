import '../model/auth_session.dart';

abstract interface class AuthenticationService {
  Future<AuthSession> signIn(String email, String password);
  Future<AuthSession> refresh(AuthSession session);
}
