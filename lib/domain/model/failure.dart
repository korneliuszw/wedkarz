enum FailureCode {
  invalidCredentials,
  offline,
  forbidden,
  expiredCode,
  invalidCode,
  invalidMeasurement,
  closedSession,
  storage,
  expiredSession,
  syncFailed,
  rateLimited,
  pushUnavailable,
  speciesUnavailable,
}

class DomainFailure implements Exception {
  const DomainFailure(this.code);
  final FailureCode code;
}

class AuthFailure extends DomainFailure {
  const AuthFailure([super.code = FailureCode.invalidCredentials]);
}

class AuthorizationFailure extends DomainFailure {
  const AuthorizationFailure() : super(FailureCode.forbidden);
}
