import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'application/providers.dart';
import 'core/theme.dart';
import 'core/widgets.dart';
import 'domain/models.dart';
import 'features/auth/login_screen.dart';
import 'features/fishing/fishing_screen.dart';
import 'features/migration/migration_screen.dart';
import 'features/more/more_screen.dart';
import 'features/records/records_screen.dart';
import 'features/water/water_screen.dart';
import 'l10n/generated/app_localizations.dart';

class NadParsetaApp extends ConsumerWidget {
  const NadParsetaApp({
    super.key,
    this.embedded = false,
    this.navigatorKey,
    this.accountActions,
    this.onBackToRoles,
  });

  final bool embedded;
  final GlobalKey<NavigatorState>? navigatorKey;
  final WidgetBuilder? accountActions;
  final VoidCallback? onBackToRoles;
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final scale = ref.watch(textScaleProvider);
    final reduceMotion = ref.watch(reducedMotionProvider);
    return MaterialApp(
      key: ValueKey(auth.valueOrNull?.user.id ?? 'signed-out'),
      navigatorKey: navigatorKey,
      title: 'Nad Parsętą',
      debugShowCheckedModeBanner: false,
      theme: createTheme(package: embedded ? 'nad_parseta' : null),
      locale: const Locale('pl'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return AnglerAssets(
          package: embedded ? 'nad_parseta' : null,
          child: MediaQuery(
            data: media.copyWith(
              textScaler: TextScaler.linear(media.textScaler.scale(1) * scale),
              disableAnimations: media.disableAnimations || reduceMotion,
            ),
            child: child!,
          ),
        );
      },
      home: AuthGate(
        accountActions: accountActions,
        onBackToRoles: onBackToRoles,
      ),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key, this.accountActions, this.onBackToRoles});

  final WidgetBuilder? accountActions;
  final VoidCallback? onBackToRoles;
  @override
  Widget build(BuildContext c, WidgetRef ref) => ref
      .watch(authProvider)
      .when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(
          body: AsyncBody<AuthSession?>(
            value: AsyncError(e, StackTrace.current),
            data: (_) => LoginScreen(onBack: onBackToRoles),
            retry: () => ref.read(authProvider.notifier).restore(),
          ),
        ),
        data: (session) => session == null
            ? LoginScreen(onBack: onBackToRoles)
            : AnglerShell(user: session.user, accountActions: accountActions),
      );
}

class AnglerShell extends ConsumerStatefulWidget {
  const AnglerShell({super.key, required this.user, this.accountActions});
  final AppUser user;
  final WidgetBuilder? accountActions;
  @override
  ConsumerState<AnglerShell> createState() => _AnglerShellState();
}

class _AnglerShellState extends ConsumerState<AnglerShell>
    with WidgetsBindingObserver {
  int _tab = 0;
  static const _moreTab = 4;

  bool _tabEnabled(int index, bool online) =>
      online || index == 0 || index == _moreTab;
  Timer? _retry;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _retry = Timer.periodic(const Duration(seconds: 30), (_) => _sync());
  }

  void _sync() {
    if (mounted) {
      unawaited(ref.read(fishingProvider(widget.user.id).notifier).sync());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _sync();
  }

  @override
  void dispose() {
    _retry?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final online = ref.watch(networkProvider).online;
    ref.watch(fishingAreasProvider);
    ref.listen(networkProvider, (previous, next) {
      if (!_tabEnabled(_tab, next.online)) setState(() => _tab = 0);
      if (next.online && previous?.online != true) _sync();
    });
    final labels = [
      c.l.registry,
      c.l.records,
      c.l.water,
      c.l.migration,
      c.l.more,
    ];
    final icons = [
      Icons.receipt_long,
      Icons.emoji_events,
      Icons.waves,
      Icons.smart_display,
      Icons.menu,
    ];
    final pages = [
      FishingScreen(user: widget.user),
      RecordsScreen(user: widget.user),
      const WaterScreen(),
      const MigrationScreen(),
      MoreScreen(user: widget.user, accountActions: widget.accountActions),
    ];
    return Scaffold(
      body: SafeArea(
        top: false,
        child: _tab == 0
            ? pages[0]
            : Column(
                children: [
                  FishingHeader(
                    title: _tab == 1 ? c.l.myRecords : labels[_tab],
                    subtitle: switch (_tab) {
                      2 => c.l.station,
                      3 => c.l.fishMigration,
                      4 =>
                        '${widget.user.displayName} · ${c.l.anglerAccountLabel}',
                      _ => null,
                    },
                  ),
                  Expanded(child: pages[_tab]),
                ],
              ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (index) {
            if (_tabEnabled(index, online)) setState(() => _tab = index);
          },
          destinations: List.generate(
            5,
            (i) => NavigationDestination(
              enabled: _tabEnabled(i, online),
              icon: Icon(
                icons[i],
                color: _tabEnabled(i, online)
                    ? AppColors.muted
                    : AppColors.disabled,
              ),
              selectedIcon: Icon(icons[i], color: AppColors.paper),
              label: labels[i],
            ),
          ),
        ),
      ),
    );
  }
}
