import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nad_parseta/app.dart';
import 'package:nad_parseta/application/providers.dart';
import 'package:nad_parseta/core/theme.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/data/local_store.dart';
import 'package:nad_parseta/domain/models.dart';
import 'package:nad_parseta/features/fishing/fishing_screen.dart';
import 'package:nad_parseta/features/fishing/new_fishing_place_screen.dart';
import 'package:nad_parseta/l10n/generated/app_localizations.dart';

class MemorySessionStore implements SessionStore {
  AuthSession? session;
  @override
  Future<AuthSession?> read() async => session;
  @override
  Future<void> write(AuthSession value) async {
    session = value;
  }

  @override
  Future<void> clear() async {
    session = null;
  }
}

class MemorySnapshotStore implements SnapshotStore {
  final snapshots = <String, AnglerSnapshot>{};
  bool rejectWrites = false;
  @override
  Future<AnglerSnapshot?> read(String ownerId) async => snapshots[ownerId];
  @override
  Future<void> write(String ownerId, AnglerSnapshot value) async {
    if (rejectWrites) throw const DomainFailure(FailureCode.storage);
    snapshots[ownerId] = AnglerSnapshot.fromJson(value.toJson());
  }
}

const testApiUrl = 'https://angler.example';
const ownerId = '42';
const testSpecies = FishSpecies(id: '2', name: 'Okoń', asset: '');
const testPlace = FishingPlace(
  id: 'river-bank',
  waterName: 'Parsęta',
  sectionName: '',
  coordinates: '54.123456,15.123456',
);

class TestNetworkController extends NetworkController {
  TestNetworkController() : super.detached();

  void goOffline() => state = const NetworkStatus(connected: false);
}

class TestHttpAdapter implements HttpClientAdapter {
  TestHttpAdapter(this.onRequest);

  final Future<ResponseBody> Function(RequestOptions) onRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => onRequest(options);

  @override
  void close({bool force = false}) {}
}

Future<ProviderContainer> createContainer({
  MemorySnapshotStore? store,
  MemorySessionStore? auth,
  Future<Position> Function()? locate,
  Future<ResponseBody> Function(RequestOptions)? onRequest,
  String url = testApiUrl,
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final snapshotStore = store ?? MemorySnapshotStore();
  final now = DateTime.now();
  snapshotStore.snapshots[ownerId] ??= AnglerSnapshot(
    activeSessionId: 'today',
    places: [testPlace],
    sessions: [
      FishingSession(
        id: 'today',
        ownerId: ownerId,
        startedAt: now.subtract(const Duration(hours: 1)),
        placeIds: [testPlace.id],
        currentPlaceId: testPlace.id,
      ),
    ],
  );
  final adapter = TestHttpAdapter((request) async {
    final resource = request.uri.path;
    if (resource == '/v1/auth/sessions') {
      final body = request.data as Json;
      if (body['accountNumber'] != 1001 || body['password'] != 'test-password') {
        return ResponseBody.fromString('', 401);
      }
    }
    final response = switch (resource) {
      '/v1/auth/sessions' || '/v1/auth/refresh' => {
        'user': {
          'id': ownerId,
          'accountNumber': 1001,
          'firstName': 'Test',
          'registerEnabled': true,
        },
        'accessToken': 'test-access',
        'refreshToken': 'test-refresh',
        'expiresIn': 3600,
      },
      '/v1/areas' => {
        'items': [
          {'id': 1, 'name': 'Parsęta'},
        ],
      },
      '/v1/species' => {
        'items': [
          {'id': 2, 'name': 'Okoń'},
        ],
      },
      '/v1/catches' || '/v1/permits' => {'items': [], 'nextBefore': null},
      _ => null,
    };
    if (response == null) {
      if (onRequest != null) return onRequest(request);
      throw StateError('Unexpected request: ${request.method} $resource');
    }
    return ResponseBody.fromString(jsonEncode(response), 200);
  });
  return ProviderContainer(
    overrides: [
      preferencesProvider.overrideWithValue(preferences),
      sessionStoreProvider.overrideWithValue(auth ?? MemorySessionStore()),
      snapshotStoreProvider.overrideWithValue(snapshotStore),
      anglerApiUrlProvider.overrideWithValue(url),
      anglerHttpAdapterFactoryProvider.overrideWithValue(() => adapter),
      speciesProvider.overrideWith((ref) => [testSpecies]),
      networkProvider.overrideWith((ref) => TestNetworkController()),
      if (locate != null)
        currentFishingPositionProvider.overrideWithValue(locate),
    ],
  );
}

void main() {
  setUpAll(() => initializeDateFormatting('pl'));

  test(
    'catch photo survives restart and retries after accounting is sent',
    () async {
      const photo = '/9j/4P/Z';
      final store = MemorySnapshotStore();
      final auth = MemorySessionStore();
      final offline = await createContainer(store: store, auth: auth);
      await offline.read(authProvider.notifier).restore();
      await offline.read(authProvider.notifier).signIn('1001', 'test-password');
      (offline.read(networkProvider.notifier) as TestNetworkController)
          .goOffline();
      final fishing = offline.read(fishingProvider(ownerId).notifier);
      await fishing.load();
      await fishing.saveCatch(
        CatchEntry(
          id: 'photo-fish',
          sessionId: 'today',
          placeId: testPlace.id,
          speciesId: testSpecies.id,
          caughtAt: DateTime.now(),
          lengthMm: 300,
          weightGrams: null,
          fate: FishFate.released,
        ),
        photoChange: (base64: photo),
      );
      expect(store.snapshots[ownerId]!.attachments.single.base64Bytes, photo);
      expect(store.snapshots[ownerId]!.outbox, isEmpty);
      await fishing.end();
      offline.dispose();

      final requests = <String>[];
      final firstPass = Completer<void>();
      var failPhoto = true;
      final online = await createContainer(
        store: store,
        auth: auth,
        onRequest: (request) async {
          requests.add(request.uri.path);
          final body = request.data as Json;
          final time = DateTime.now().toIso8601String();
          if (request.uri.path == '/v1/fishing-sessions') {
            return ResponseBody.fromString(
              jsonEncode({'id': body['id'], 'receivedAt': time}),
              201,
            );
          }
          expect(request.method, 'PUT');
          expect(body['base64'], photo);
          if (failPhoto) return ResponseBody.fromString('', 503);
          return ResponseBody.fromString(
            jsonEncode({'clientId': 'photo-fish', 'receivedAt': time}),
            200,
          );
        },
      );
      addTearDown(online.dispose);
      await online.read(authProvider.notifier).restore();
      final status = online.listen(syncingProvider, (previous, syncing) {
        if (previous == true && !syncing && !firstPass.isCompleted) {
          firstPass.complete();
        }
      });
      final restarted = online.read(fishingProvider(ownerId).notifier);
      await firstPass.future;
      status.close();
      expect(requests, [
        '/v1/fishing-sessions',
        '/v1/catches/photo-fish/photo',
      ]);
      expect(store.snapshots[ownerId]!.outbox.single.kind, SyncKind.attachment);
      expect(store.snapshots[ownerId]!.attachments.single.syncedAt, isNull);
      failPhoto = false;
      await restarted.sync();
      expect(requests.last, '/v1/catches/photo-fish/photo');
      expect(requests.length, 3);
      expect(store.snapshots[ownerId]!.outbox, isEmpty);
      expect(store.snapshots[ownerId]!.attachments.single.syncedAt, isNotNull);
    },
  );

  testWidgets('missing API configuration prevents sign-in', (tester) async {
    final container = await createContainer(url: '');
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const NadParsetaApp(),
      ),
    );
    await tester.pumpAndSettle();

    final l = lookupAppLocalizations(const Locale('pl'));
    expect(find.text(l.apiNotConfigured), findsOneWidget);
    expect(find.byKey(const Key('sign-in')), findsNothing);
    expect(container.read(authProvider).requireValue, isNull);
  });

  test('API rejection leaves the angler signed out', () async {
    final container = await createContainer();
    addTearDown(container.dispose);
    final auth = container.read(authProvider.notifier);
    await auth.restore();

    await expectLater(
      auth.signIn('1001', 'wrong-password'),
      throwsA(
        isA<AuthFailure>().having(
          (error) => error.code,
          'code',
          FailureCode.invalidCredentials,
        ),
      ),
    );
    expect(container.read(authProvider).requireValue, isNull);
    expect(await container.read(sessionStoreProvider).read(), isNull);
  });
  test('Penpot ink applies to the custom type styles', () {
    final text = createTheme().textTheme;
    expect([
      text.headlineLarge?.color,
      text.headlineMedium?.color,
      text.headlineSmall?.color,
      text.titleLarge?.color,
      text.titleMedium?.color,
      text.bodyLarge?.color,
      text.bodyMedium?.color,
    ], everyElement(const Color(0xFF101412)));
    expect(text.bodySmall?.color, const Color(0xFF3A4640));
  });
  testWidgets('unknown retained mass is not displayed as zero kilograms', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pl'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: AccountingSummary(
            entries: [
              CatchEntry(
                id: 'unknown',
                sessionId: 'session',
                placeId: 'parseta-a',
                speciesId: testSpecies.id,
                caughtAt: DateTime.now(),
                lengthMm: 280,
                weightGrams: null,
                fate: FishFate.retained,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('0,00 kg'), findsNothing);
    expect(find.textContaining('— kg'), findsOneWidget);
  });
  testWidgets('offline keeps the account switch available in More', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 892);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = await createContainer();
    var switched = false;
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: NadParsetaApp(
          accountActions: (_) => OutlinedButton(
            onPressed: () => switched = true,
            child: const Text('Przełącz tryb · Strażnik'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('login-email')), '1001');
    await tester.enterText(
      find.byKey(const Key('login-password')),
      'test-password',
    );
    await tester.ensureVisible(find.byKey(const Key('sign-in')));
    await tester.tap(find.byKey(const Key('sign-in')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('add-catch')), findsOneWidget);
    (container.read(networkProvider.notifier) as TestNetworkController)
        .goOffline();
    await tester.pumpAndSettle();
    final destinations = tester
        .widgetList<NavigationDestination>(find.byType(NavigationDestination))
        .toList();
    expect(destinations.first.enabled, isTrue);
    expect(destinations.sublist(1, 4).every((e) => !e.enabled), isTrue);
    expect(destinations.last.enabled, isTrue);
    expect(find.text('Pokaż kod strażnikowi'), findsNothing);
    expect(find.text('Przełącz tryb · Strażnik'), findsNothing);
    final add = tester.getRect(find.byKey(const Key('add-catch')));
    final end = tester.getRect(find.widgetWithText(OutlinedButton, 'Zakończ'));
    expect(add.top, end.top);
    expect(add.right, lessThan(end.left));
    await tester.tap(find.text('Więcej'));
    await tester.pumpAndSettle();
    final permits = find.widgetWithText(MenuPanel, 'Zezwolenia');
    expect(tester.widget<MenuPanel>(permits).onTap, isNull);
    await tester.tap(find.text('Konta'));
    await tester.pumpAndSettle();
    expect(find.text('Konta'), findsOneWidget);
    await tester.tap(find.text('Przełącz tryb · Strażnik'));
    expect(switched, isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('registry and form reflow at 320px with 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final now = DateTime.now();
    final auth = MemorySessionStore()
      ..session = AuthSession(
        user: const AppUser(
          id: ownerId,
          displayName: 'Test',
          email: '1001',
          role: UserRole.angler,
          registerEnabled: true,
        ),
        accessToken: 'test-access',
        refreshToken: 'test-refresh',
        accessExpiresAt: now.add(const Duration(hours: 1)),
        refreshExpiresAt: now.add(const Duration(days: 7)),
      );
    final container = await createContainer(auth: auth);
    container.read(textScaleProvider.notifier).state = 2;
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const NadParsetaApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const Key('add-catch')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('catch-length')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('new place requires area and GPS before saving a custom name', (
    tester,
  ) async {
    var gpsRequests = 0;
    final store = MemorySnapshotStore();
    final container = await createContainer(
      store: store,
      locate: () async {
        gpsRequests++;
        return Position(
          latitude: 54.123456,
          longitude: 15.123456,
          timestamp: DateTime.now(),
          accuracy: 1,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      },
    );
    addTearDown(container.dispose);
    final signingIn = container
        .read(authProvider.notifier)
        .signIn('1001', 'test-password');
    await tester.pump(const Duration(milliseconds: 180));
    await signingIn;
    final owner = container.read(authProvider).requireValue!.user.id;
    final l = lookupAppLocalizations(const Locale('pl'));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('pl'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => pushPage(
                  context,
                  NewFishingPlaceScreen(ownerId: owner, start: false),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(gpsRequests, 0);
    expect(
      tester
          .widget<OutlinedButton>(
            find.ancestor(
              of: find.text(l.getFishingCoordinates),
              matching: find.byWidgetPredicate(
                (widget) => widget is OutlinedButton,
              ),
            ),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Parsęta').last);
    await tester.pumpAndSettle();
    expect(gpsRequests, 0);
    await tester.tap(find.text(l.getFishingCoordinates));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Przy moście');
    await tester.ensureVisible(find.text(l.fishHere));
    await tester.tap(find.text(l.fishHere));
    await tester.pumpAndSettle();
    final place = store.snapshots[owner]!.places.last;
    expect(gpsRequests, 1);
    expect(place.label, 'Przy moście');
    expect(place.registerLocation, '54.123456,15.123456');
  });

  test('offline catch and outbox survive a new repository instance', () async {
    final store = MemorySnapshotStore();
    final container = await createContainer(store: store);
    await container.read(authProvider.notifier).restore();
    await container.read(authProvider.notifier).signIn('1001', 'test-password');
    (container.read(networkProvider.notifier) as TestNetworkController)
        .goOffline();
    final controller = container.read(fishingProvider(ownerId).notifier);
    await controller.load();
    final session = container
        .read(fishingProvider(ownerId))
        .requireValue
        .activeSession!;
    await controller.saveCatch(
      CatchEntry(
        id: 'offline-fish',
        sessionId: session.id,
        placeId: session.currentPlaceId,
        speciesId: testSpecies.id,
        caughtAt: DateTime.now(),
        lengthMm: 310,
        weightGrams: 400,
        fate: FishFate.released,
      ),
    );
    await controller.end();
    final restored = await LocalFishingRepository(ownerId, store).read();
    expect(restored.catches.any((e) => e.id == 'offline-fish'), isTrue);
    expect(restored.outbox.single.entityId, session.id);
    expect(restored.outbox.single.payload['places'], [testPlace.coordinates]);
    expect(
      (restored.outbox.single.payload['catches'] as List).single['clientId'],
      'offline-fish',
    );
    container.dispose();
  });

  test(
    'failed durable save does not publish a catch or a record celebration',
    () async {
      final store = MemorySnapshotStore();
      final container = await createContainer(store: store);
      await container.read(authProvider.notifier).restore();
      await container
          .read(authProvider.notifier)
          .signIn('1001', 'test-password');
      (container.read(networkProvider.notifier) as TestNetworkController)
          .goOffline();
      final controller = container.read(fishingProvider(ownerId).notifier);
      await controller.load();
      final before = container.read(fishingProvider(ownerId)).requireValue;
      store.rejectWrites = true;
      final session = before.activeSession!;
      await expectLater(
        controller.saveCatch(
          CatchEntry(
            id: 'unsaved',
            sessionId: session.id,
            placeId: session.currentPlaceId,
            speciesId: testSpecies.id,
            caughtAt: DateTime.now(),
            lengthMm: 990,
            weightGrams: 9000,
            fate: FishFate.released,
          ),
        ),
        throwsA(isA<DomainFailure>()),
      );
      expect(
        container.read(fishingProvider(ownerId)).requireValue.catches.length,
        before.catches.length,
      );
      expect(container.read(achievementProvider), isNull);
      container.dispose();
    },
  );
}
