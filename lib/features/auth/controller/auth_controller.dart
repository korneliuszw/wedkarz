import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nad_parseta/features/auth/service/authentication_service.dart';
import 'package:nad_parseta/domain/models.dart';
import 'package:nad_parseta/application/storage_providers.dart';
import 'package:nad_parseta/features/fishing/controller/fishing_status.dart';
import 'package:nad_parseta/application/network_controller.dart';

final authServiceProvider = Provider<AuthenticationService>(
  (ref) => ref.watch(anglerApiProvider),
);

final authProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthSession?>>(
      (ref) => AuthController(ref),
    );

class AuthController extends StateNotifier<AsyncValue<AuthSession?>> {
  AuthController(this._ref) : super(const AsyncLoading()) {
    unawaited(restore());
  }
  final Ref _ref;
  Future<AuthSession>? _refreshing;
  Future<void>? _restoring;
  int _sessionVersion = 0;

  Future<void> restore() =>
      _restoring ??= _restore().whenComplete(() => _restoring = null);

  Future<void> _restore() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await _ref.read(sessionStoreProvider).read();
      if (session == null || session.user.role != UserRole.angler) return null;
      if (!session.canRefreshAt(DateTime.now())) {
        await _ref.read(sessionStoreProvider).clear();
        return null;
      }
      if (_ref.read(networkProvider).online) {
        try {
          final verified = await _ref
              .read(authServiceProvider)
              .refresh(session);
          await _ref.read(sessionStoreProvider).write(verified);
          return verified;
        } on AuthFailure {
          await _ref.read(sessionStoreProvider).clear();
          return null;
        } on DomainFailure {
          return session;
        }
      }
      return session;
    });
  }

  Future<void> signIn(String email, String password) async {
    if (!_ref.read(networkProvider).online) {
      throw const DomainFailure(FailureCode.offline);
    }
    final version = _sessionVersion;
    final session = await _ref
        .read(authServiceProvider)
        .signIn(email, password);
    if (!mounted || version != _sessionVersion) return;
    await _ref.read(sessionStoreProvider).write(session);
    state = AsyncData(session);
  }

  Future<AuthSession> requireOnline({UserRole? role}) async {
    if (!_ref.read(networkProvider).online) {
      throw const DomainFailure(FailureCode.offline);
    }
    final session = state.valueOrNull;
    if (session == null) throw const AuthFailure(FailureCode.expiredSession);
    if (role != null && session.user.role != role) {
      throw const AuthorizationFailure();
    }
    if (!session.needsRefreshAt(DateTime.now())) return session;
    return _refreshing ??= _refresh(
      session,
    ).whenComplete(() => _refreshing = null);
  }

  Future<AuthSession> _refresh(AuthSession session) async {
    try {
      final next = await _ref.read(authServiceProvider).refresh(session);
      if (!identical(state.valueOrNull, session)) {
        throw const AuthFailure(FailureCode.expiredSession);
      }
      await _ref.read(sessionStoreProvider).write(next);
      state = AsyncData(next);
      return next;
    } on AuthFailure {
      if (identical(state.valueOrNull, session)) await _clearSession();
      rethrow;
    }
  }

  Future<void> signOut() async {
    _sessionVersion++;
    await _restoring;
    final pending = _refreshing;
    if (pending != null) {
      try {
        await pending;
      } catch (_) {}
    }
    final session = state.valueOrNull;
    if (session != null && _ref.read(networkProvider).online) {
      try {
        final current = await requireOnline();
        await _ref
            .read(anglerApiProvider)
            .request('DELETE', 'auth/sessions/current', session: current);
      } on DomainFailure {
        // Local sign-out must work even when the API is unreachable.
      }
    }
    await _clearSession();
  }

  Future<void> _clearSession() async {
    await _ref.read(sessionStoreProvider).clear();
    _ref.read(achievementProvider.notifier).state = null;
    state = const AsyncData(null);
  }

  Future<T> apiRequest<T>(Future<T> Function(AuthSession) action) async {
    final session = await requireOnline(role: UserRole.angler);
    try {
      return await action(session);
    } on AuthFailure {
      final current = state.valueOrNull;
      if (current == null || current.user.id != session.user.id) rethrow;
      final renewed = identical(current, session)
          ? await (_refreshing ??= _refresh(
              session,
            ).whenComplete(() => _refreshing = null))
          : current;
      return action(renewed);
    }
  }

  Future<void> acceptRegister() async {
    final api = _ref.read(anglerApiProvider);
    await apiRequest((current) async {
      await api.acceptRegister(current);
      if (!identical(state.valueOrNull, current)) return;
      final next = current.withRegisterEnabled();
      await _ref.read(sessionStoreProvider).write(next);
      if (identical(state.valueOrNull, current)) state = AsyncData(next);
    });
  }
}
