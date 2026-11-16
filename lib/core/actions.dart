import 'package:flutter/material.dart';
import 'package:nad_parseta/domain/models.dart';
import 'package:nad_parseta/core/context.dart';

String failureText(BuildContext c, Object error) => switch (error) {
  DomainFailure(code: FailureCode.invalidCredentials) => c.l.invalidCredentials,
  DomainFailure(code: FailureCode.offline) => c.l.offlineError,
  DomainFailure(code: FailureCode.forbidden) => c.l.forbidden,
  DomainFailure(code: FailureCode.expiredCode) => c.l.expiredCode,
  DomainFailure(code: FailureCode.invalidCode) => c.l.invalidCode,
  DomainFailure(code: FailureCode.invalidMeasurement) => c.l.invalidMeasurement,
  DomainFailure(code: FailureCode.closedSession) => c.l.closedSession,
  DomainFailure(code: FailureCode.storage) => c.l.storageError,
  DomainFailure(code: FailureCode.expiredSession) => c.l.expiredSession,
  DomainFailure(code: FailureCode.syncFailed) => c.l.syncFailed,
  DomainFailure(code: FailureCode.rateLimited) => c.l.rateLimited,
  DomainFailure(code: FailureCode.pushUnavailable) => c.l.pushUnavailable,
  DomainFailure(code: FailureCode.speciesUnavailable) => c.l.speciesUnavailable,
  _ => c.l.genericError,
};
void showFailure(BuildContext c, Object error) {
  if (!c.mounted) return;
  ScaffoldMessenger.of(
    c,
  ).showSnackBar(SnackBar(content: Text(failureText(c, error))));
}

Future<bool> runAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
    return true;
  } catch (error) {
    if (context.mounted) showFailure(context, error);
    return false;
  }
}

void pushPage(BuildContext c, Widget page) =>
    Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => page));
