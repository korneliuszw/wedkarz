// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get chooseFishingArea => 'Wybierz obszar';

  @override
  String get getFishingCoordinates => 'Pobierz aktualne współrzędne';

  @override
  String get locatingFishingPlace => 'Pobieranie współrzędnych…';

  @override
  String get optionalFishingPlaceName => 'Nazwa miejsca (opcjonalnie)';

  @override
  String get fishingLocationUnavailable =>
      'Nie udało się pobrać współrzędnych. Sprawdź uprawnienia i usługi lokalizacji, a następnie spróbuj ponownie.';

  @override
  String get noFishingAreas => 'Brak dostępnych obszarów.';

  @override
  String get savedFishingPlaces => 'Zapisane miejsca';

  @override
  String get appTitle => 'Nad Parsętą';

  @override
  String get staleWater =>
      'Brak nowszego pomiaru. Pokazujemy ostatni dostępny stan wody.';

  @override
  String get imgwWaterSource => 'Źródło pomiarów: IMGW-PIB.';

  @override
  String get submitFishingSession => 'Zakończ i wyślij';

  @override
  String get submitFishingSessionHint =>
      'Po zakończeniu wpisy zostaną wysłane, gdy wróci internet. Nie będzie można ich zmienić.';

  @override
  String get inspectionOfflineHint =>
      'Przygotuj zezwolenia przy połączeniu z internetem. Potem kod działa offline.';

  @override
  String get refreshInspection => 'Pobierz dane do kontroli offline';

  @override
  String inspectionPage(int page, int count) {
    return 'Część $page z $count';
  }

  @override
  String get pushUnavailable =>
      'Powiadomienia są niedostępne na tym urządzeniu lub wymagają zgody.';

  @override
  String get reminderTime => 'Godzina przypomnienia (czas polski)';

  @override
  String get accountNumber => 'Numer wędkarza';

  @override
  String get invalidAccountCredentials =>
      'Nieprawidłowy numer wędkarza lub hasło.';

  @override
  String get rateLimited =>
      'Za dużo prób logowania. Spróbuj ponownie za 15 minut.';

  @override
  String get registerConsentTitle => 'Rejestr elektroniczny';

  @override
  String get registerConsentText =>
      'Wybieram rejestr elektroniczny i będę prowadzić go na bieżąco, zgodnie ze stanem faktycznym.';

  @override
  String get acceptRegister => 'Wybieram rejestr elektroniczny';

  @override
  String get speciesUnavailable =>
      'Lista gatunków jest niedostępna. Połącz się z internetem i spróbuj ponownie.';

  @override
  String get loginTitle => 'Rejestr połowów';

  @override
  String get email => 'Adres e-mail';

  @override
  String get password => 'Hasło';

  @override
  String get signIn => 'Zaloguj się';

  @override
  String get apiNotConfigured =>
      'Brak adresu API wędkarskiego. Skontaktuj się z administratorem aplikacji.';

  @override
  String get anglerAccount => 'Wędkarz';

  @override
  String get rangerAccount => 'Strażnik';

  @override
  String get loading => 'Wczytywanie…';

  @override
  String get retry => 'Spróbuj ponownie';

  @override
  String get save => 'Zapisz';

  @override
  String get cancel => 'Anuluj';

  @override
  String get back => 'Wróć';

  @override
  String get close => 'Zamknij';

  @override
  String get done => 'Gotowe';

  @override
  String get logout => 'Wyloguj się';

  @override
  String get requiredField => 'Uzupełnij to pole.';

  @override
  String get invalidNumber => 'Wpisz poprawną liczbę większą od zera.';

  @override
  String get requiredFate => 'Wybierz: wypuszczona lub zabrana.';

  @override
  String get invalidCredentials => 'Nieprawidłowy adres e-mail lub hasło.';

  @override
  String get offlineError => 'Brak połączenia. Rejestr działa offline.';

  @override
  String get forbidden => 'Brak uprawnień do tych danych.';

  @override
  String get expiredCode => 'Kod wygasł. Poproś o nowy kod.';

  @override
  String get invalidCode => 'Nie rozpoznano kodu kontroli.';

  @override
  String get invalidMeasurement => 'Sprawdź pomiary, miejsce i godzinę połowu.';

  @override
  String get closedSession => 'Ta sesja jest zakończona.';

  @override
  String get storageError =>
      'Nie udało się zapisać danych na urządzeniu. Spróbuj ponownie.';

  @override
  String get expiredSession => 'Sesja logowania wygasła. Zaloguj się ponownie.';

  @override
  String get syncFailed => 'Nie wysłano wpisów. Dane pozostają na urządzeniu.';

  @override
  String get genericError =>
      'Nie udało się wykonać tej czynności. Spróbuj ponownie.';

  @override
  String get registry => 'Rejestr';

  @override
  String get records => 'Rekordy';

  @override
  String get water => 'Woda';

  @override
  String get migration => 'Nagrania';

  @override
  String get more => 'Więcej';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Brak internetu';

  @override
  String get onlineOnly => 'Dostępne online';

  @override
  String get fishing => 'Łowienie';

  @override
  String get startFishing => 'Zacznij dzień';

  @override
  String get addFish => 'Dodaj rybę';

  @override
  String get endSession => 'Zakończ dzień';

  @override
  String get endSessionShort => 'Zakończ';

  @override
  String get endQuestion => 'Zakończyć dzień?';

  @override
  String get allPlaces => 'Wszystkie miejsca';

  @override
  String get place => 'Miejsce';

  @override
  String get placeReady => 'Miejsce gotowe';

  @override
  String get firstCatchHint => 'Tu nie ma jeszcze żadnej ryby.';

  @override
  String get places => 'Miejsca';

  @override
  String get placeOptions => 'Opcje miejsca';

  @override
  String get addPlace => 'Dodaj nowe miejsce';

  @override
  String get changePlace => 'Zmień miejsce';

  @override
  String get allSessionFish => 'Wszystkie ryby z dzisiaj';

  @override
  String get allFish => 'Ryby z dzisiaj';

  @override
  String get fish => 'Ryby';

  @override
  String get emptyPlace => 'Brak ryb w tym miejscu';

  @override
  String get noActiveSession => 'Dziś jeszcze nie łowisz';

  @override
  String get recentSessions => 'Poprzednie dni';

  @override
  String get noCatch => 'Bez połowu';

  @override
  String get currentPlace => 'Tu łowisz';

  @override
  String get species => 'Gatunek';

  @override
  String get length => 'Długość';

  @override
  String get weight => 'Masa';

  @override
  String get fate => 'Los ryby';

  @override
  String get released => 'Wypuszczona';

  @override
  String get retained => 'Zabrana';

  @override
  String get releasedTotal => 'Wypuszczone';

  @override
  String get retainedTotal => 'Zabrane';

  @override
  String get caughtTime => 'Godzina połowu';

  @override
  String get photo => 'Zdjęcie ryby';

  @override
  String get takeCatchPhoto => 'Zrób zdjęcie';

  @override
  String get retakeCatchPhoto => 'Zrób nowe zdjęcie';

  @override
  String get removeCatchPhoto => 'Usuń zdjęcie';

  @override
  String get catchPhotoTooLarge => 'Zdjęcie jest za duże. Zrób je ponownie.';

  @override
  String get catchCameraUnavailable =>
      'Nie udało się otworzyć aparatu lub zapisać zdjęcia.';

  @override
  String get catchPhotoPending =>
      'Zdjęcie zapisane na urządzeniu, czeka na wysłanie.';

  @override
  String get catchPhotoSent => 'Zdjęcie wysłane.';

  @override
  String get optional => 'Opcjonalne';

  @override
  String get measurementHelp => 'Wystarczy długość albo masa.';

  @override
  String get saveFish => 'Zapisz rybę';

  @override
  String get fishSaved => 'Zapisano na urządzeniu';

  @override
  String get editFish => 'Popraw wpis';

  @override
  String get deleteFish => 'Usuń wpis';

  @override
  String get deleteQuestion => 'Usunąć wpis?';

  @override
  String get delete => 'Usuń';

  @override
  String get newRecord => 'Nowy rekord!';

  @override
  String get firstRecord => 'Twój pierwszy rekord!';

  @override
  String get myRecords => 'Twoje rekordy';

  @override
  String get noRecord =>
      'Pierwszy rekord przed Tobą. Zapisz rybę z długością albo masą.';

  @override
  String get speciesIllustration => 'Ilustracja gatunku';

  @override
  String get unknownWeight => 'Część masy nie została podana';

  @override
  String get received => 'Wysłano do Związku';

  @override
  String get pending => 'Do wysłania';

  @override
  String get sending => 'Wysyłam…';

  @override
  String get sendingEntries => 'Wysyłanie wpisów';

  @override
  String get trySend => 'Spróbuj ponownie';

  @override
  String get sessionRecord => 'Sesja połowu';

  @override
  String get attachment => 'Zdjęcie';

  @override
  String get lastReceipt => 'Ostatni odbiór';

  @override
  String get permits => 'Zezwolenia';

  @override
  String get myPermits => 'Moje zezwolenia';

  @override
  String get permit => 'Zezwolenie';

  @override
  String get buyPermit => 'Kup zezwolenie';

  @override
  String get externalPurchase => 'Zakup odbywa się na stronie Związku.';

  @override
  String get purchaseNotConfigured => 'Adres sklepu jest niedostępny.';

  @override
  String get noValidPermit => 'Nie masz ważnego zezwolenia';

  @override
  String get validUntil => 'Ważne do';

  @override
  String get validFrom => 'Ważne od';

  @override
  String get expiredPermits => 'Wygasłe zezwolenia';

  @override
  String get permitNumber => 'Numer';

  @override
  String get angler => 'Wędkarz';

  @override
  String get area => 'Obszar';

  @override
  String get showControl => 'Pokaż kod strażnikowi';

  @override
  String get controlCode => 'Kod dla strażnika';

  @override
  String get validFor => 'Ważny jeszcze';

  @override
  String get showToRanger => 'Pokaż ten ekran strażnikowi';

  @override
  String get controlScope => 'Zobaczy Twoje zezwolenie i dzisiejsze ryby.';

  @override
  String get codeExpiredTitle => 'Kod wygasł';

  @override
  String get regenerateCode => 'Pokaż nowy kod';

  @override
  String get preparingCode =>
      'Najpierw wysyłam dzisiejsze ryby. Kod pojawi się za chwilę.';

  @override
  String get reminders => 'Przypomnienia';

  @override
  String get sevenDaysBefore => '7 dni przed końcem';

  @override
  String get oneDayBefore => '1 dzień przed końcem';

  @override
  String get reminderHour => 'Godzina';

  @override
  String get reminderSaved => 'Ustawienia przypomnień zapisane';

  @override
  String get expiresToday => 'Zezwolenie wygasa dziś';

  @override
  String expiresInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Zezwolenie wygasa za $days dni',
      one: 'Zezwolenie wygasa jutro',
    );
    return '$_temp0';
  }

  @override
  String get waterLevel => 'Poziom wody';

  @override
  String get station => 'Parsęta · stacja przykładowa';

  @override
  String get day => '24 godz.';

  @override
  String get week => '7 dni';

  @override
  String get month => '30 dni';

  @override
  String get readingTable => 'Odczyty w tabeli';

  @override
  String get measuredAt => 'Pomiar';

  @override
  String get noReading => 'Brak pomiaru';

  @override
  String get noRecordings => 'Brak dostępnych nagrań.';

  @override
  String get fishMigration => 'Wędrówki ryb';

  @override
  String get fishPass => 'Przepławka';

  @override
  String get recording => 'Nagranie';

  @override
  String get play => 'Odtwórz';

  @override
  String get pause => 'Pauza';

  @override
  String get readability => 'Czytelność';

  @override
  String get largeText => 'Większy tekst';

  @override
  String get reduceMotion => 'Ogranicz animacje';

  @override
  String get help => 'Pomoc';

  @override
  String get helpSteps =>
      '1. Zacznij dzień i wybierz miejsce.\n2. Dodaj każdą rybę, także wypuszczoną.\n3. Użyj przycisku „Zmień miejsce”, gdy przeniesiesz się nad wodą.\n4. Zakończ dzień, również bez połowu.';

  @override
  String get simulateOffline => 'Symuluj brak internetu';

  @override
  String get failNextSync => 'Przetestuj błąd następnej wysyłki';

  @override
  String get signOutQuestion =>
      'Wylogować się? Wpisy na urządzeniu zostaną zachowane.';

  @override
  String get guardControl => 'Kontrola wędkarza';

  @override
  String get controlReference => 'Kod kontroli / odnośnik QR';

  @override
  String get checkCode => 'Sprawdź kod';

  @override
  String get currentSession => 'Bieżąca sesja';

  @override
  String get noCurrentSession => 'Brak bieżącej sesji';

  @override
  String get refresh => 'Odśwież';

  @override
  String get sessionEnded => 'Dzisiejszy połów zapisany.';

  @override
  String get copyCode => 'Kopiuj kod';

  @override
  String get copied => 'Skopiowano';

  @override
  String get menu => 'Menu';

  @override
  String get receivedShort => 'Wysłano';

  @override
  String get pendingShort => 'Czeka';

  @override
  String get sendFailedShort => 'Nie wysłano';

  @override
  String get localOffline =>
      'Ryby są zapisane na telefonie.\nBez internetu działa tylko Rejestr.';

  @override
  String get localSaved => 'Wpisy są zapisane na telefonie.';

  @override
  String get todayAllPlaces => 'Dzisiaj, wszystkie miejsca';

  @override
  String get whereFishing => 'Gdzie teraz łowisz?';

  @override
  String get newPlaceTitle => 'Nowe miejsce';

  @override
  String get fishHere => 'Łowię tutaj';

  @override
  String get placeChangeHint =>
      'Zmiana miejsca nie rusza ryb zapisanych wcześniej.';

  @override
  String get chooseSpecies => 'Wybierz gatunek';

  @override
  String get whichSpecies => 'Jaka to ryba?';

  @override
  String get chooseSpeciesFirst => 'Najpierw wybierz gatunek.';

  @override
  String get fatePrompt => 'Co z rybą?';

  @override
  String get saveCorrection => 'Zapisz poprawkę';

  @override
  String get offlineCatch => 'Brak internetu. Ryba zapisze się na telefonie.';

  @override
  String get longest => 'Najdłuższe';

  @override
  String get heaviest => 'Najcięższe';

  @override
  String get recordsHint =>
      'Największa ryba każdego gatunku, także wypuszczona.';

  @override
  String get previousRecord => 'Poprzedni';

  @override
  String get dayEndedTitle => 'Dzień zakończony';

  @override
  String get startNewDay => 'Zacznij nowy dzień';

  @override
  String get keepFishing => 'Łowię dalej';

  @override
  String get noFishToday => 'Dziś bez ryb';

  @override
  String get endWithoutFish => 'Zakończ dzień bez ryb';

  @override
  String get startDayHint =>
      'Zacznij dzień i wybierz miejsce. Ryby dopiszesz później.';

  @override
  String get login => 'Login';

  @override
  String get yourPhoto => 'Twoje zdjęcie';

  @override
  String get speciesCaption =>
      'Ilustracja gatunku. To nie jest zdjęcie Twojej ryby.';

  @override
  String get measurements => 'Pomiary';

  @override
  String get anglerAccountLabel => 'konto wędkarza';

  @override
  String get showPermit => 'Pokaż zezwolenie';

  @override
  String get offlineCode =>
      'Kod działa tylko z internetem. Dzisiejsze ryby są zapisane na telefonie i możesz je pokazać strażnikowi w Rejestrze.';

  @override
  String get correctionHint => 'Poprawka zmieni ten wpis. Nie doda nowej ryby.';

  @override
  String get keepEntry => 'Zostaw wpis';

  @override
  String get deleteHint => 'Ryba zniknie z rozliczenia i z rekordów.';

  @override
  String get noFishDayHint =>
      'Taki dzień też się liczy. Zapiszemy sam dzień nad wodą.';

  @override
  String get closeCode => 'Zamknij kod';

  @override
  String get permitPeriod => 'Okres';

  @override
  String get expiryDay => 'W dniu końca';

  @override
  String get saveReminders => 'Zapisz przypomnienia';

  @override
  String get expiredCodeHint =>
      'Minęły 2 minuty. Zezwolenie i ryby są bez zmian.';

  @override
  String placeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miejsc',
      few: '$count miejsca',
      one: '1 miejsce',
    );
    return '$_temp0';
  }

  @override
  String fishCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ryb',
      few: '$count ryby',
      one: '1 ryba',
    );
    return '$_temp0';
  }

  @override
  String dayBalance(int released, int retained, String mass) {
    String _temp0 = intl.Intl.pluralLogic(
      released,
      locale: localeName,
      other: '$released wypuszczonych',
      few: '$released wypuszczone',
      one: '1 wypuszczona',
    );
    String _temp1 = intl.Intl.pluralLogic(
      retained,
      locale: localeName,
      other: '$retained zabranych',
      few: '$retained zabrane',
      one: '1 zabrana',
    );
    return '$_temp0, $_temp1 ($mass)';
  }

  @override
  String get accounts => 'Konta';

  @override
  String get salmon => 'Łosoś';

  @override
  String get seaTrout => 'Troć wędrowna';

  @override
  String get videoUnavailable => 'Nie można odtworzyć nagrania.';

  @override
  String get section => 'Odcinek';

  @override
  String get noMorePlaces => 'Wszystkie dostępne miejsca są już dodane.';

  @override
  String get expiredOn => 'Wygasło';

  @override
  String get placeNotChanged => 'Ryby z poprzednich miejsc zostają bez zmian.';

  @override
  String get checkPurchase => 'Sprawdź ponownie';

  @override
  String get purchasePending => 'Czekamy na potwierdzenie Związku.';

  @override
  String get purchasePendingHint =>
      'Zezwolenie pojawi się tutaj, gdy Związek potwierdzi zakup.';

  @override
  String get noExpiredPermits => 'Brak wygasłych zezwoleń';

  @override
  String get noPermitHint =>
      'Kupisz je na stronie Związku. Po zakupie wróć tutaj.';
}
