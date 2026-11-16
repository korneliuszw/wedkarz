# Data and adapters

All fixture data is synthetic. Never import the ranger application's real tokens, certificates or personal data into fixtures. `catalog.dart` resolves stored place labels and supplies species illustrations.

`LocalFishingRepository` serializes updates. Construct next state, persist, then publish. A failed write leaves current state intact. Scope snapshots by authenticated owner. Logout does not clear catches or outbox. Corrupt snapshots surface a recoverable error instead of a reset.

`PreferencesSnapshotStore` is intentionally replaceable. Browser quota/eviction and SharedPreferences limits make it unsuitable for production catch accounting/media. Add schema migrations and storage-capacity handling; do not silently truncate records.

Production sync contract:

1. Submit stable operation ID, entity ID, exact revision and payload, authenticated as owner.
2. Server authorizes ownership and validates domain data. Deduplicate operation IDs durably.
3. ACK includes operation/revision and server receipt time. Remove only that acknowledged operation locally.
4. ACK of an old revision must not mark a newer local edit synchronized.
5. Partial success preserves failed/newer operations. Retry with backoff; no duplicate fish.
6. Process legacy pending single-catch operations before a newer closed-session batch. The offline presentation can include device-reported catches before acknowledgement.
7. Save the optional Android JPEG with the local catch. Queue its attachment ID when the session closes and upload its bytes after the catch receipt. Retain it for retry until the photo API acknowledges it.

`angler_api.dart` submits immutable closed sessions via `POST /v1/fishing-sessions` with the same session and catch UUIDs on every retry. Remove an operation only after a matching receipt and persist any signed receipt with the local session. Keep tokens in secure storage and use a stable device ID. Paginate history and permits, preserve legacy quantity and date-only values, and scope snapshots by endpoint and owner.

Authentication validates token expiry, rotates refresh values and handles refresh failure without erasing unsent data. Never log passwords, raw QR references or session tokens. API authorization is enforced on the server. Offline inspection verifies signatures against a pinned root on the ranger device.

Offline inspection credentials are provisioned over HTTPS. Android stores device keys in Android Keystore. PWA stores non-extractable Web Crypto keys in IndexedDB. The locally signed presentation expires after 120 seconds and carries all catches from the presented session across places. Never log QR payloads.

Purchase verification is server-owned. Opening a browser or receiving a return URL does not create a permit. Permits are read-only downloads. `PURCHASE_URL` is empty by default and must be an approved HTTPS shop URL.
