# Nad Parsętą — Flutter POC

This directory is the authoritative new angler app. The existing ranger app lives in `../aplikacja/zezwolenia-zwiazek-mobile` and hosts the offline inspection scanner. Preserve its existing permit and report flows. Set `ANGLER_API_URL` to use the HTTP API in `../wedkarz-serwer`. The standalone app also accepts `API_URL`.

## Product and platforms

Polish anglers, roughly 40–90, outdoors and with intermittent connectivity. Android native and mobile web/PWA for iPhone. Design reference: Penpot **New File 2**, page **05 · Spławik — nowy wygląd**. Use the olive header, reed background, Sofia Sans type, orange primary actions and text labels for sync states. The combined Android app hosts the angler and ranger workspaces.

Implemented journeys include API sign-in, local fishing sessions, catch editing, records, outbox and retry, IMGW readings, permits, reminders and signed offline QR inspection.

## Run and check

Verified SDK: Flutter 3.32.0 / Dart 3.8.0. Android minimum API 24, NDK 27.0.12077973. Dependencies are locked; do not upgrade the SDK or unrelated packages as a routine change.

```sh
flutter pub get
flutter gen-l10n
dart format lib test
flutter analyze
flutter test
flutter run -d chrome --dart-define=ANGLER_API_URL=http://localhost:3001
flutter run -d <android-device> --dart-define=ANGLER_API_URL=https://your-api.example
flutter build apk --debug
flutter build web --release --no-web-resources-cdn --pwa-strategy=offline-first
```

Optional configured purchase URL:

```sh
flutter run -d chrome --dart-define=PURCHASE_URL=https://the-approved-shop.example
```

The example hostname above is documentation, not a configured shop. Default URL is deliberately empty; the button displays a POC message and never pretends a payment occurred. Only configured absolute HTTPS URLs may be launched.

Serve `build/web` over HTTPS, or localhost during development. A first online load/install is required before offline use. `python -m http.server 4178 --bind 127.0.0.1 --directory build/web` is a local preview, not hosting.

## Architecture

- `domain/`: shared JSON and error types, accounting and record rules, and the model exports used by the combined app.
- `data/`: shared HTTP transport and platform integrations.
- `application/`: shared storage and connectivity providers. `providers.dart` re-exports feature providers for the app entry points.
- `features/`: feature-specific UI, Riverpod controllers, models, services and repositories. Fishing session edits and outbox synchronization have separate controllers. Session storage lives under auth, and snapshot persistence under fishing.
- `core/`: shared accessible UI, formatting, colors and theme.
- `l10n/app_pl.arb`: user-facing strings; generated Dart is in `l10n/generated/`.

Patterns checked against Strażnik: Riverpod controllers/`AsyncValue`, UI→controller→service/repository→storage separation, secure access/refresh session handling, per-feature UI, ARB localization. The POC intentionally uses handwritten Riverpod providers and model JSON instead of Freezed/build_runner, so **build_runner is not required in this app**. Do not apply ranger-only SQLCipher/native adapter/background/Firebase assumptions to web code.

## Core invariants

Sign-in uses the legacy numeric account number. The client requires explicit register consent, caches the server species catalog and imports catch history. Active sessions are local drafts. Ending a session queues its immutable snapshot for a single API submission. Submitted or queued fish are read-only. Scope snapshots by API endpoint and account.

1. One session can contain several places. Switching place never changes earlier fish. Returning does not duplicate a place. New catches default to the currently selected place.
2. Each fish has a stable ID, session ID, place ID, species, timestamp, optional length/weight, explicit released/retained choice and revision. At least one measurement is required in this POC. Use integer millimeters and grams; unknown is null, not zero.
3. Released and retained counts are separate. Only retained fish contribute to retained biomass. Flag incomplete totals when retained weights are unknown.
4. Local transaction succeeds before the UI reports save/record success. Persistence failures must not publish optimistic accounting state.
5. Outbox operation UUID + entity ID + revision + immutable revision payload survive restart. Retry the same UUID. New edits make new operations, not another fish.
6. Data operations are drained before photo operations. Offline QR includes pending catches as device-reported and shows server acknowledgement only when a signed receipt matches. Offline/retry/failure never deletes unsent entries.
7. Personal records are per species, separately by length and weight, including released fish. Strictly greater only; first record has no zero baseline. Deleted catches are excluded. No repeated celebrations on sync.
8. Ending a session includes all its places and fish, including zero-fish days. Pending upload remains reachable from the registry after ending.

## Access and authentication

Offline, the registry and More remain available. Permits, records, water and recordings require a connection. The signed inspection QR is reachable from More once provisioned, and Konta can switch to a saved workspace offline. Network recovery, resume, saves and foreground retry trigger synchronization through the selected adapter. Connectivity indicates transport availability. Failed HTTP requests keep catches in the local queue.

FlutterSecureStorage stores API access and refresh credentials. PWA needs HTTPS or localhost. Combined Android snapshots use SQLCipher. Standalone snapshots use SharedPreferences behind `SnapshotStore`. Use an appropriate transactional web store before deploying with real personal data.

## QR control

The signed offline protocol in `../inspection_protocol` presents catches from the current session and expires after 120 seconds. See the API README for trust provisioning and ranger verification.

## Integrations

- Push registration requires a configured Firebase project.
- Permit purchases only launch the configured external site. Re-fetch after return; a redirect never proves payment.
- API-mode reminder preferences and device tokens are persisted on the backend. The Firebase scheduler delivers notifications when configured. Installed iPhone PWAs require Web Push permission.
- Recordings plays HTTPS media from the API when available.
- Background uploads after app/PWA closure are not implemented. iPhone closed-app upload must never be promised.

## Before connecting an API

Use the current contract in `../wedkarz-serwer/README.md` when configuring an endpoint. Server validates owner, role, session and resource scope. Photo uploads and corrections to submitted catches are outside the current API contract.

See scoped AGENTS.md files for model contracts, storage/authorization and UI/PWA details. Run meaningful regression tests for changed rules and `flutter analyze` before delivery. Never edit generated localization files by hand or discard snapshots to mask a migration/parse error.

## POC verification — 2026-11-06

20 automated tests pass, covering role/expiry checks, idempotent retry, accounting/record rules, offline tab restrictions, durable restart, failed-write behavior and 320px layouts with 200% text. Android debug APK and release web bundle were built with the commands above. Android hardware execution and Safari/iPhone installation have not been tested.

Browser smoke checks at 412×892: demo login, adding a third place, saving a released 30cm perch, inline record feedback, persistence after reload, permit detail and QR, and ranger lookup showing all four current-session catches across three places. A cached PWA reloaded while network requests failed. Chrome's emulated offline mode did not change `navigator.onLine`; disabled-tab behavior was checked through the explicit demo mode and automated tests. Screenshots: `docs/qa/poc-record.png` and `docs/qa/poc-qr.png`.

## Penpot visual update — 2026-11-07

Implemented the latest page 04 logbook details: fish-and-river header, native vector float/reeds empty-state illustration, localized empty-place copy, species illustration with personal-record feedback, and static rulers on the records list. Preserve the 420 ms ruler reveal and reduced-motion behavior. Decorative painters are excluded from semantics. Narrow/enlarged-text headers move the connection control to a separate row instead of reducing type size.

Verified after changes: `flutter analyze`, all 20 existing tests (including 320px / 200% text), release PWA and debug APK builds. Local browser at 412×892: login, empty third place, saved released 34cm/0.50kg perch and new record. Screenshots: `docs/qa/poc-delight-registry.png`, `poc-delight-empty.png`, `poc-delight-record.png`. Hardware Android and Safari/iPhone checks remain outstanding.
