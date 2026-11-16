# Domain models

Keep models independent of widgets and plugins. JSON uses stable camelCase fields, enum names, UTC ISO-8601 instants and null for unknown values. `schemaVersion` in snapshots is the migration boundary; never silently overwrite an unreadable persisted snapshot.

| Model | Key fields and responsibility |
| --- | --- |
| AppUser | id, displayName, email, `angler`/`ranger` role |
| AuthSession | user, access/refresh values, separate expiry timestamps |
| FishingPlace | stable id, waterName, sectionName; optional area ID, coordinates and custom name |
| FishSpecies | stable id, localized display data and bundled illustration asset; approved catalog still needed |
| FishingSession | id, ownerId, startedAt, endedAt, unique placeIds, currentPlaceId, revision, nullable submittedAt and signedReceipt |
| CatchEntry | id, sessionId, placeId, speciesId, caughtAt, nullable lengthMm/weightGrams, fate, revision, deletedAt, syncedAt |
| CatchAttachment | id, catchId, bounded local base64 photo bytes, createdAt, independent syncedAt |
| SyncOperation | stable operation/idempotency id, entityId, kind, revision, createdAt, copied immutable revision payload |
| AnglerSnapshot | sessions, catches, attachments, durable outbox, activeSessionId, reminder preferences, last receipt |
| Permit | id, ownerId, number, areaName, validFrom, **exclusive** validUntil |
| ReminderSettings | sevenDays, oneDay, expiryDay, Warsaw hour; API mode persists preferences for FCM delivery |
| WaterReading | measuredAt, nullable levelCm; missing is not 0 |
| MigrationRecording | id, recordedAt, durationSeconds, nullable mediaUrl |

`rules.dart` owns accounting, strict record comparison and catch/session consistency. Do not sum released weights into extraction totals, invent missing masses or make a tie a new record. Session selection preserves IDs and earlier assignments. Measurement sanity bounds are technical POC bounds, **not species-specific legal limits**.

Production API date-only permit validity must be mapped explicitly to the organization's timezone and exclusive end instant. The UI displays `validUntil - 1 microsecond`; do not shorten a valid final day accidentally.

Outbox payload must describe its exact revision, even if the current entity has already been edited again. Photo operations resolve bytes by attachment ID. Deleting a draft catch also removes its local photo. Closed catches and their photos are read-only.

Future server model candidates: Angler/User, AuthSession/Device, Water, FishingSection, Species, FishingSession, SessionPlace/Visit, CatchEntry, Attachment, OutboxReceipt, Permit, ControlReference, ReminderSubscription, WaterGauge/Reading, MigrationStation/Recording. Visits may be added separately if per-place effort/time intervals are required; current POC tracks catch timestamps, not a full visit timeline.
