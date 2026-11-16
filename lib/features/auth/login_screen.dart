import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers.dart';
import '../../core/widgets.dart';
import '../../core/theme.dart';
import '../../domain/models.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.onBack});

  final VoidCallback? onBack;
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _account = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _account.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authProvider.notifier)
          .signIn(_account.text, _password.text);
    } catch (e) {
      if (mounted) {
        setState(
          () => _error =
              e is DomainFailure && e.code == FailureCode.invalidCredentials
              ? context.l.invalidAccountCredentials
              : failureText(context, e),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    final configured = ref.watch(anglerApiUrlProvider).isNotEmpty;
    return Scaffold(
      appBar: widget.onBack == null
          ? null
          : AppBar(leading: BackButton(onPressed: widget.onBack)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: PageBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: SizedBox(
                          width: 42,
                          height: 76,
                          child: FittedBox(child: FloatMark()),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        c.l.appTitle,
                        textAlign: TextAlign.center,
                        style: c.text.headlineLarge?.copyWith(
                          color: AppColors.paper,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        c.l.loginTitle,
                        textAlign: TextAlign.center,
                        style: c.text.bodyLarge?.copyWith(
                          color: AppColors.soft,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            PageBody(
              child: !configured
                  ? Text(c.l.apiNotConfigured)
                  : AutofillGroup(
                      child: Form(
                        key: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LabeledField(
                              label: c.l.accountNumber,
                              child: TextFormField(
                                key: const Key('login-email'),
                                controller: _account,
                                keyboardType: TextInputType.number,
                                autofillHints: const [AutofillHints.username],
                                validator: (v) =>
                                    v == null ||
                                        !RegExp(
                                          r'^[0-9]{1,10}$',
                                        ).hasMatch(v.trim())
                                    ? c.l.requiredField
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 24),
                            LabeledField(
                              label: c.l.password,
                              child: TextFormField(
                                key: const Key('login-password'),
                                controller: _password,
                                obscureText: true,
                                autofillHints: const [AutofillHints.password],
                                onFieldSubmitted: (_) => _signIn(),
                                validator: (v) => v == null || v.isEmpty
                                    ? c.l.requiredField
                                    : null,
                              ),
                            ),
                            if (_error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Semantics(
                                  liveRegion: true,
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      color: Theme.of(c).colorScheme.error,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 32),
                            FilledButton(
                              key: const Key('sign-in'),
                              onPressed: _busy || !configured ? null : _signIn,
                              child: Text(_busy ? c.l.loading : c.l.signIn),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
