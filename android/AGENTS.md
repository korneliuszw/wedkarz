# Android POC

Minimum API 24; NDK 27.0.12077973 matches the installed toolchain and Flutter/plugin requirements. Internet and network-state permissions are in the main manifest. App backup is disabled and cleartext traffic is disallowed. ImagePicker uses platform camera/photo-picker integration; don't add broad storage permissions unnecessarily.

`gradle.properties` disables Kotlin incremental compilation and uses in-process compilation because this Windows workspace is on J: while the Pub cache is on C:. Kotlin's relocatable incremental caches otherwise fail with “this and base files have different roots”. Keep this workaround scoped to this app; don't rewrite the user's global Gradle/JDK configuration.

The debug APK is under `build/app/outputs/flutter-apk/app-debug.apk`. It has been built, not run on a physical Android device during this task. Release signing in the generated template still uses the debug configuration: **do not publish it**. Configure the organization's real application ID, signing and store metadata before distribution.

Permit reminders use FCM with runtime notification permission and server-side scheduling. Session uploads retry from the durable outbox when the app is active or resumes. Android signing uses the shared Keystore channel in `app/src/inspection/kotlin`, registered by both the standalone and combined Android app entry points.
