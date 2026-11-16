# Nad Parsętą — Flutter POC

Android i mobilna PWA z trwałym rejestrem lokalnym. Aplikacja wymaga adresu API wędkarskiego. Do logowania służy numer konta i hasło. Tryb Strażnika jest dostępny w połączonej aplikacji Android.

## Uruchomienie lokalne

Uruchom bazę demonstracyjną i serwer według [instrukcji API](../wedkarz-serwer/README.md). Następnie uruchom aplikację z tego katalogu.

```sh
flutter pub get
flutter gen-l10n
flutter run -d chrome --web-hostname localhost --web-port 4183 --dart-define=API_URL=http://localhost:3001
```

Na emulatorze Android użyj `flutter run --dart-define=API_URL=http://10.0.2.2:3001`. Dla urządzenia fizycznego skonfiguruj adres HTTPS osiągalny z telefonu.

Konto testowe `910001` ma aktywny rejestr i przykładowe połowy. Konto `910002` zaczyna od deklaracji wyboru rejestru elektronicznego. Hasło obu kont to `ParsetaDemo123!`.

Po pierwszym pobraniu gatunków i akceptacji deklaracji można zapisywać ryby offline. Zakończenie dnia umieszcza całą sesję w kolejce do wysłania. Aplikacja wysyła ją po odzyskaniu połączenia i wyświetla potwierdzenie z API. Przed zakończeniem dnia można poprawiać lokalne wpisy. Ekran wody pokazuje dane IMGW z pamięci podręcznej serwera. Ekran nagrań wyświetla filmy HTTPS udostępnione przez API.

Architektura, modele, reguły i komendy są opisane w [AGENTS.md](AGENTS.md) oraz plikach AGENTS.md w lib/domain, lib/data, lib/features i web.

## Weryfikacja i build

```sh
flutter analyze
flutter test
flutter build apk --debug --dart-define=ANGLER_API_URL=https://adres-api
flutter build web --release --no-web-resources-cdn --pwa-strategy=offline-first --dart-define=ANGLER_API_URL=https://adres-api
```

Przycisk zakupu używa `--dart-define=PURCHASE_URL=https://adres-sklepu`. Adres pozostaje do ustalenia.

## Kontrola w terenie

Skonfiguruj API według [instrukcji PKI](../wedkarz-serwer/README.md#offline-inspection-pki). Obie aplikacje buduj z tym samym `--dart-define=INSPECTION_ROOT_PUBLIC_KEY=...`. Strażnik dodatkowo otrzymuje `--dart-define=ANGLER_API_URL=https://...`. Przed wyjazdem wędkarz synchronizuje zezwolenia, a strażnik aktualizuje dane wystawcy. Przy kontroli wędkarz otwiera kod z rejestru połowu. Strażnik skanuje go raz w aplikacji. Oba urządzenia mogą pozostać offline. Ekran pokazuje dane zezwolenia i rozróżnia wpisy urządzenia od połowów potwierdzonych przez serwer.

## Powiadomienia Firebase

Do klienta przekaż publiczne `FIREBASE_PROJECT_ID`, `FIREBASE_SENDER_ID`, `FIREBASE_API_KEY` oraz odpowiednio `FIREBASE_ANDROID_APP_ID` albo `FIREBASE_WEB_APP_ID` i `FIREBASE_VAPID_KEY` przez `--dart-define`. Dla PWA wypełnij publiczną konfigurację w `web/firebase-messaging-config.js` przed budowaniem i serwuj `firebase-messaging-sw.js` z tego samego originu HTTPS. iPhone wymaga instalacji PWA na ekranie początkowym i zgody użytkownika na powiadomienia. W połączonej aplikacji Android ustawienia wędkarza muszą wskazywać projekt i aplikację Firebase używane przez jej domyślną konfigurację. Klucz prywatny konta Firebase pozostaje na serwerze. Rzeczywistą dostawę należy sprawdzić na urządzeniach po konfiguracji projektu Firebase.
