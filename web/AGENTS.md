# Mobile PWA

Build with `flutter build web --release --no-web-resources-cdn --pwa-strategy=offline-first` using the verified Flutter 3.32 SDK. `manifest.json` defines Polish title, standalone mode, scope/start URL, brand colors and normal/maskable icons. Keep viewport-fit=cover and accessible zoom; do not add user-scalable=no.

Serve over HTTPS in deployment. Localhost is suitable for development and secure-storage testing; opening index.html as file:// is not. Secure storage, service workers, camera and Web Push have secure-context requirements.

The current SDK's generated Flutter service worker provides the POC cache. The page requests its `downloadOffline` action after startup so app assets/fonts/illustrations can be retained for offline re-entry. Do not cache authentication endpoints, control-token responses, personal API responses or purchase pages when a real API is added. Reassess Flutter service-worker deprecation/custom-worker strategy when upgrading SDK.

Initial installation/load needs the internet. Verify offline reload after warming cache, not only disabling UI tabs. Client snapshots/outbox remain separate from app-shell cache; app updates/logout must not clear unsent data. Browser storage can still be evicted, so production persistence/backup policy is a separate deliverable.

iPhone reminder delivery needs an installed Home Screen PWA, user permission and configured Firebase on the client and API. Keep `firebase-messaging-sw.js` scoped for FCM and separate from the Flutter offline worker. See the app README for public config values. Closed-app PWA uploads are not guaranteed: retry automatically while active and on resume/reopen, display pending count and server acknowledgement.

Keep font and fish assets local. Do not restore CDN-only CanvasKit/font dependencies if offline launch is required. Treat existing photographed catches as sensitive user content; don't export auth/localStorage dumps in QA artifacts.
