# Mobile UI rules

Polish strings belong in `lib/l10n/app_pl.arb`, accessed with `context.l`. Penpot page 05 supplies the UI reference. Use bundled Sofia Sans for body text and Sofia Sans Condensed for headings and primary actions. The shared theme defines the olive header, orange primary action, yellow waiting state, and white panels. Reserve outlines for controls.

Keep 48-pixel tap targets, readable field labels, explicit catch fate, a list of water readings, and accessible layout at large text sizes. Preserve the original offline policy. Use device preferences for reduced motion. The registry header shows one connection state when there is pending work, a failure, or an offline connection. In the catch list, show sent/pending text from the catch receipt and use the angler's photo when available.

The place picker switches between existing places, adds a place to the active day, and opens the catches from all places. Record notices appear after a successful local save. Render a previous measurement only when one exists. Keep the short 420 ms ruler reveal and static reduced-motion version. Keep actual timestamps for corrections. Capture new catch times when saving.

Offline: the registry and More stay available. Online-only destinations and menu rows are disabled individually. Open the signed inspection QR and the account switch from More. Switching to an existing account works offline.

Permits are reached from More and the registry shortcut online. Buy launches external browser directly; no fake payment screen. QR has a dedicated screen and absolute countdown; never keep drawing an expired QR. Close/logout must remove privileged screens, and switching users must reset navigation state.

Login uses API-backed angler accounts. The Strażnik workspace in the combined app scans signed QR presentations offline.

Water shows cached IMGW observations and freshness. Recordings plays HTTPS recordings supplied by the API. Reminder preferences register an FCM device when enabled and surface denied or unavailable notification permissions.
