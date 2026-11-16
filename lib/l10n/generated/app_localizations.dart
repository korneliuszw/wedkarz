import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('pl')];

  /// No description provided for @chooseFishingArea.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz obszar'**
  String get chooseFishingArea;

  /// No description provided for @getFishingCoordinates.
  ///
  /// In pl, this message translates to:
  /// **'Pobierz aktualne współrzędne'**
  String get getFishingCoordinates;

  /// No description provided for @locatingFishingPlace.
  ///
  /// In pl, this message translates to:
  /// **'Pobieranie współrzędnych…'**
  String get locatingFishingPlace;

  /// No description provided for @optionalFishingPlaceName.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa miejsca (opcjonalnie)'**
  String get optionalFishingPlaceName;

  /// No description provided for @fishingLocationUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się pobrać współrzędnych. Sprawdź uprawnienia i usługi lokalizacji, a następnie spróbuj ponownie.'**
  String get fishingLocationUnavailable;

  /// No description provided for @noFishingAreas.
  ///
  /// In pl, this message translates to:
  /// **'Brak dostępnych obszarów.'**
  String get noFishingAreas;

  /// No description provided for @savedFishingPlaces.
  ///
  /// In pl, this message translates to:
  /// **'Zapisane miejsca'**
  String get savedFishingPlaces;

  /// No description provided for @appTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nad Parsętą'**
  String get appTitle;

  /// No description provided for @staleWater.
  ///
  /// In pl, this message translates to:
  /// **'Brak nowszego pomiaru. Pokazujemy ostatni dostępny stan wody.'**
  String get staleWater;

  /// No description provided for @imgwWaterSource.
  ///
  /// In pl, this message translates to:
  /// **'Źródło pomiarów: IMGW-PIB.'**
  String get imgwWaterSource;

  /// No description provided for @submitFishingSession.
  ///
  /// In pl, this message translates to:
  /// **'Zakończ i wyślij'**
  String get submitFishingSession;

  /// No description provided for @submitFishingSessionHint.
  ///
  /// In pl, this message translates to:
  /// **'Po zakończeniu wpisy zostaną wysłane, gdy wróci internet. Nie będzie można ich zmienić.'**
  String get submitFishingSessionHint;

  /// No description provided for @inspectionOfflineHint.
  ///
  /// In pl, this message translates to:
  /// **'Przygotuj zezwolenia przy połączeniu z internetem. Potem kod działa offline.'**
  String get inspectionOfflineHint;

  /// No description provided for @refreshInspection.
  ///
  /// In pl, this message translates to:
  /// **'Pobierz dane do kontroli offline'**
  String get refreshInspection;

  /// No description provided for @inspectionPage.
  ///
  /// In pl, this message translates to:
  /// **'Część {page} z {count}'**
  String inspectionPage(int page, int count);

  /// No description provided for @pushUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Powiadomienia są niedostępne na tym urządzeniu lub wymagają zgody.'**
  String get pushUnavailable;

  /// No description provided for @reminderTime.
  ///
  /// In pl, this message translates to:
  /// **'Godzina przypomnienia (czas polski)'**
  String get reminderTime;

  /// No description provided for @accountNumber.
  ///
  /// In pl, this message translates to:
  /// **'Numer wędkarza'**
  String get accountNumber;

  /// No description provided for @invalidAccountCredentials.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowy numer wędkarza lub hasło.'**
  String get invalidAccountCredentials;

  /// No description provided for @rateLimited.
  ///
  /// In pl, this message translates to:
  /// **'Za dużo prób logowania. Spróbuj ponownie za 15 minut.'**
  String get rateLimited;

  /// No description provided for @registerConsentTitle.
  ///
  /// In pl, this message translates to:
  /// **'Rejestr elektroniczny'**
  String get registerConsentTitle;

  /// No description provided for @registerConsentText.
  ///
  /// In pl, this message translates to:
  /// **'Wybieram rejestr elektroniczny i będę prowadzić go na bieżąco, zgodnie ze stanem faktycznym.'**
  String get registerConsentText;

  /// No description provided for @acceptRegister.
  ///
  /// In pl, this message translates to:
  /// **'Wybieram rejestr elektroniczny'**
  String get acceptRegister;

  /// No description provided for @speciesUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Lista gatunków jest niedostępna. Połącz się z internetem i spróbuj ponownie.'**
  String get speciesUnavailable;

  /// No description provided for @loginTitle.
  ///
  /// In pl, this message translates to:
  /// **'Rejestr połowów'**
  String get loginTitle;

  /// No description provided for @email.
  ///
  /// In pl, this message translates to:
  /// **'Adres e-mail'**
  String get email;

  /// No description provided for @password.
  ///
  /// In pl, this message translates to:
  /// **'Hasło'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się'**
  String get signIn;

  /// No description provided for @apiNotConfigured.
  ///
  /// In pl, this message translates to:
  /// **'Brak adresu API wędkarskiego. Skontaktuj się z administratorem aplikacji.'**
  String get apiNotConfigured;

  /// No description provided for @anglerAccount.
  ///
  /// In pl, this message translates to:
  /// **'Wędkarz'**
  String get anglerAccount;

  /// No description provided for @rangerAccount.
  ///
  /// In pl, this message translates to:
  /// **'Strażnik'**
  String get rangerAccount;

  /// No description provided for @loading.
  ///
  /// In pl, this message translates to:
  /// **'Wczytywanie…'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj ponownie'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get cancel;

  /// No description provided for @back.
  ///
  /// In pl, this message translates to:
  /// **'Wróć'**
  String get back;

  /// No description provided for @close.
  ///
  /// In pl, this message translates to:
  /// **'Zamknij'**
  String get close;

  /// No description provided for @done.
  ///
  /// In pl, this message translates to:
  /// **'Gotowe'**
  String get done;

  /// No description provided for @logout.
  ///
  /// In pl, this message translates to:
  /// **'Wyloguj się'**
  String get logout;

  /// No description provided for @requiredField.
  ///
  /// In pl, this message translates to:
  /// **'Uzupełnij to pole.'**
  String get requiredField;

  /// No description provided for @invalidNumber.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz poprawną liczbę większą od zera.'**
  String get invalidNumber;

  /// No description provided for @requiredFate.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz: wypuszczona lub zabrana.'**
  String get requiredFate;

  /// No description provided for @invalidCredentials.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowy adres e-mail lub hasło.'**
  String get invalidCredentials;

  /// No description provided for @offlineError.
  ///
  /// In pl, this message translates to:
  /// **'Brak połączenia. Rejestr działa offline.'**
  String get offlineError;

  /// No description provided for @forbidden.
  ///
  /// In pl, this message translates to:
  /// **'Brak uprawnień do tych danych.'**
  String get forbidden;

  /// No description provided for @expiredCode.
  ///
  /// In pl, this message translates to:
  /// **'Kod wygasł. Poproś o nowy kod.'**
  String get expiredCode;

  /// No description provided for @invalidCode.
  ///
  /// In pl, this message translates to:
  /// **'Nie rozpoznano kodu kontroli.'**
  String get invalidCode;

  /// No description provided for @invalidMeasurement.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź pomiary, miejsce i godzinę połowu.'**
  String get invalidMeasurement;

  /// No description provided for @closedSession.
  ///
  /// In pl, this message translates to:
  /// **'Ta sesja jest zakończona.'**
  String get closedSession;

  /// No description provided for @storageError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać danych na urządzeniu. Spróbuj ponownie.'**
  String get storageError;

  /// No description provided for @expiredSession.
  ///
  /// In pl, this message translates to:
  /// **'Sesja logowania wygasła. Zaloguj się ponownie.'**
  String get expiredSession;

  /// No description provided for @syncFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie wysłano wpisów. Dane pozostają na urządzeniu.'**
  String get syncFailed;

  /// No description provided for @genericError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wykonać tej czynności. Spróbuj ponownie.'**
  String get genericError;

  /// No description provided for @registry.
  ///
  /// In pl, this message translates to:
  /// **'Rejestr'**
  String get registry;

  /// No description provided for @records.
  ///
  /// In pl, this message translates to:
  /// **'Rekordy'**
  String get records;

  /// No description provided for @water.
  ///
  /// In pl, this message translates to:
  /// **'Woda'**
  String get water;

  /// No description provided for @migration.
  ///
  /// In pl, this message translates to:
  /// **'Nagrania'**
  String get migration;

  /// No description provided for @more.
  ///
  /// In pl, this message translates to:
  /// **'Więcej'**
  String get more;

  /// No description provided for @online.
  ///
  /// In pl, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In pl, this message translates to:
  /// **'Brak internetu'**
  String get offline;

  /// No description provided for @onlineOnly.
  ///
  /// In pl, this message translates to:
  /// **'Dostępne online'**
  String get onlineOnly;

  /// No description provided for @fishing.
  ///
  /// In pl, this message translates to:
  /// **'Łowienie'**
  String get fishing;

  /// No description provided for @startFishing.
  ///
  /// In pl, this message translates to:
  /// **'Zacznij dzień'**
  String get startFishing;

  /// No description provided for @addFish.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj rybę'**
  String get addFish;

  /// No description provided for @endSession.
  ///
  /// In pl, this message translates to:
  /// **'Zakończ dzień'**
  String get endSession;

  /// No description provided for @endSessionShort.
  ///
  /// In pl, this message translates to:
  /// **'Zakończ'**
  String get endSessionShort;

  /// No description provided for @endQuestion.
  ///
  /// In pl, this message translates to:
  /// **'Zakończyć dzień?'**
  String get endQuestion;

  /// No description provided for @allPlaces.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie miejsca'**
  String get allPlaces;

  /// No description provided for @place.
  ///
  /// In pl, this message translates to:
  /// **'Miejsce'**
  String get place;

  /// No description provided for @placeReady.
  ///
  /// In pl, this message translates to:
  /// **'Miejsce gotowe'**
  String get placeReady;

  /// No description provided for @firstCatchHint.
  ///
  /// In pl, this message translates to:
  /// **'Tu nie ma jeszcze żadnej ryby.'**
  String get firstCatchHint;

  /// No description provided for @places.
  ///
  /// In pl, this message translates to:
  /// **'Miejsca'**
  String get places;

  /// No description provided for @placeOptions.
  ///
  /// In pl, this message translates to:
  /// **'Opcje miejsca'**
  String get placeOptions;

  /// No description provided for @addPlace.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj nowe miejsce'**
  String get addPlace;

  /// No description provided for @changePlace.
  ///
  /// In pl, this message translates to:
  /// **'Zmień miejsce'**
  String get changePlace;

  /// No description provided for @allSessionFish.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie ryby z dzisiaj'**
  String get allSessionFish;

  /// No description provided for @allFish.
  ///
  /// In pl, this message translates to:
  /// **'Ryby z dzisiaj'**
  String get allFish;

  /// No description provided for @fish.
  ///
  /// In pl, this message translates to:
  /// **'Ryby'**
  String get fish;

  /// No description provided for @emptyPlace.
  ///
  /// In pl, this message translates to:
  /// **'Brak ryb w tym miejscu'**
  String get emptyPlace;

  /// No description provided for @noActiveSession.
  ///
  /// In pl, this message translates to:
  /// **'Dziś jeszcze nie łowisz'**
  String get noActiveSession;

  /// No description provided for @recentSessions.
  ///
  /// In pl, this message translates to:
  /// **'Poprzednie dni'**
  String get recentSessions;

  /// No description provided for @noCatch.
  ///
  /// In pl, this message translates to:
  /// **'Bez połowu'**
  String get noCatch;

  /// No description provided for @currentPlace.
  ///
  /// In pl, this message translates to:
  /// **'Tu łowisz'**
  String get currentPlace;

  /// No description provided for @species.
  ///
  /// In pl, this message translates to:
  /// **'Gatunek'**
  String get species;

  /// No description provided for @length.
  ///
  /// In pl, this message translates to:
  /// **'Długość'**
  String get length;

  /// No description provided for @weight.
  ///
  /// In pl, this message translates to:
  /// **'Masa'**
  String get weight;

  /// No description provided for @fate.
  ///
  /// In pl, this message translates to:
  /// **'Los ryby'**
  String get fate;

  /// No description provided for @released.
  ///
  /// In pl, this message translates to:
  /// **'Wypuszczona'**
  String get released;

  /// No description provided for @retained.
  ///
  /// In pl, this message translates to:
  /// **'Zabrana'**
  String get retained;

  /// No description provided for @releasedTotal.
  ///
  /// In pl, this message translates to:
  /// **'Wypuszczone'**
  String get releasedTotal;

  /// No description provided for @retainedTotal.
  ///
  /// In pl, this message translates to:
  /// **'Zabrane'**
  String get retainedTotal;

  /// No description provided for @caughtTime.
  ///
  /// In pl, this message translates to:
  /// **'Godzina połowu'**
  String get caughtTime;

  /// No description provided for @photo.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcie ryby'**
  String get photo;

  /// No description provided for @takeCatchPhoto.
  ///
  /// In pl, this message translates to:
  /// **'Zrób zdjęcie'**
  String get takeCatchPhoto;

  /// No description provided for @retakeCatchPhoto.
  ///
  /// In pl, this message translates to:
  /// **'Zrób nowe zdjęcie'**
  String get retakeCatchPhoto;

  /// No description provided for @removeCatchPhoto.
  ///
  /// In pl, this message translates to:
  /// **'Usuń zdjęcie'**
  String get removeCatchPhoto;

  /// No description provided for @catchPhotoTooLarge.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcie jest za duże. Zrób je ponownie.'**
  String get catchPhotoTooLarge;

  /// No description provided for @catchCameraUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się otworzyć aparatu lub zapisać zdjęcia.'**
  String get catchCameraUnavailable;

  /// No description provided for @catchPhotoPending.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcie zapisane na urządzeniu, czeka na wysłanie.'**
  String get catchPhotoPending;

  /// No description provided for @catchPhotoSent.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcie wysłane.'**
  String get catchPhotoSent;

  /// No description provided for @optional.
  ///
  /// In pl, this message translates to:
  /// **'Opcjonalne'**
  String get optional;

  /// No description provided for @measurementHelp.
  ///
  /// In pl, this message translates to:
  /// **'Wystarczy długość albo masa.'**
  String get measurementHelp;

  /// No description provided for @saveFish.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz rybę'**
  String get saveFish;

  /// No description provided for @fishSaved.
  ///
  /// In pl, this message translates to:
  /// **'Zapisano na urządzeniu'**
  String get fishSaved;

  /// No description provided for @editFish.
  ///
  /// In pl, this message translates to:
  /// **'Popraw wpis'**
  String get editFish;

  /// No description provided for @deleteFish.
  ///
  /// In pl, this message translates to:
  /// **'Usuń wpis'**
  String get deleteFish;

  /// No description provided for @deleteQuestion.
  ///
  /// In pl, this message translates to:
  /// **'Usunąć wpis?'**
  String get deleteQuestion;

  /// No description provided for @delete.
  ///
  /// In pl, this message translates to:
  /// **'Usuń'**
  String get delete;

  /// No description provided for @newRecord.
  ///
  /// In pl, this message translates to:
  /// **'Nowy rekord!'**
  String get newRecord;

  /// No description provided for @firstRecord.
  ///
  /// In pl, this message translates to:
  /// **'Twój pierwszy rekord!'**
  String get firstRecord;

  /// No description provided for @myRecords.
  ///
  /// In pl, this message translates to:
  /// **'Twoje rekordy'**
  String get myRecords;

  /// No description provided for @noRecord.
  ///
  /// In pl, this message translates to:
  /// **'Pierwszy rekord przed Tobą. Zapisz rybę z długością albo masą.'**
  String get noRecord;

  /// No description provided for @speciesIllustration.
  ///
  /// In pl, this message translates to:
  /// **'Ilustracja gatunku'**
  String get speciesIllustration;

  /// No description provided for @unknownWeight.
  ///
  /// In pl, this message translates to:
  /// **'Część masy nie została podana'**
  String get unknownWeight;

  /// No description provided for @received.
  ///
  /// In pl, this message translates to:
  /// **'Wysłano do Związku'**
  String get received;

  /// No description provided for @pending.
  ///
  /// In pl, this message translates to:
  /// **'Do wysłania'**
  String get pending;

  /// No description provided for @sending.
  ///
  /// In pl, this message translates to:
  /// **'Wysyłam…'**
  String get sending;

  /// No description provided for @sendingEntries.
  ///
  /// In pl, this message translates to:
  /// **'Wysyłanie wpisów'**
  String get sendingEntries;

  /// No description provided for @trySend.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj ponownie'**
  String get trySend;

  /// No description provided for @sessionRecord.
  ///
  /// In pl, this message translates to:
  /// **'Sesja połowu'**
  String get sessionRecord;

  /// No description provided for @attachment.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcie'**
  String get attachment;

  /// No description provided for @lastReceipt.
  ///
  /// In pl, this message translates to:
  /// **'Ostatni odbiór'**
  String get lastReceipt;

  /// No description provided for @permits.
  ///
  /// In pl, this message translates to:
  /// **'Zezwolenia'**
  String get permits;

  /// No description provided for @myPermits.
  ///
  /// In pl, this message translates to:
  /// **'Moje zezwolenia'**
  String get myPermits;

  /// No description provided for @permit.
  ///
  /// In pl, this message translates to:
  /// **'Zezwolenie'**
  String get permit;

  /// No description provided for @buyPermit.
  ///
  /// In pl, this message translates to:
  /// **'Kup zezwolenie'**
  String get buyPermit;

  /// No description provided for @externalPurchase.
  ///
  /// In pl, this message translates to:
  /// **'Zakup odbywa się na stronie Związku.'**
  String get externalPurchase;

  /// No description provided for @purchaseNotConfigured.
  ///
  /// In pl, this message translates to:
  /// **'Adres sklepu jest niedostępny.'**
  String get purchaseNotConfigured;

  /// No description provided for @noValidPermit.
  ///
  /// In pl, this message translates to:
  /// **'Nie masz ważnego zezwolenia'**
  String get noValidPermit;

  /// No description provided for @validUntil.
  ///
  /// In pl, this message translates to:
  /// **'Ważne do'**
  String get validUntil;

  /// No description provided for @validFrom.
  ///
  /// In pl, this message translates to:
  /// **'Ważne od'**
  String get validFrom;

  /// No description provided for @expiredPermits.
  ///
  /// In pl, this message translates to:
  /// **'Wygasłe zezwolenia'**
  String get expiredPermits;

  /// No description provided for @permitNumber.
  ///
  /// In pl, this message translates to:
  /// **'Numer'**
  String get permitNumber;

  /// No description provided for @angler.
  ///
  /// In pl, this message translates to:
  /// **'Wędkarz'**
  String get angler;

  /// No description provided for @area.
  ///
  /// In pl, this message translates to:
  /// **'Obszar'**
  String get area;

  /// No description provided for @showControl.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż kod strażnikowi'**
  String get showControl;

  /// No description provided for @controlCode.
  ///
  /// In pl, this message translates to:
  /// **'Kod dla strażnika'**
  String get controlCode;

  /// No description provided for @validFor.
  ///
  /// In pl, this message translates to:
  /// **'Ważny jeszcze'**
  String get validFor;

  /// No description provided for @showToRanger.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż ten ekran strażnikowi'**
  String get showToRanger;

  /// No description provided for @controlScope.
  ///
  /// In pl, this message translates to:
  /// **'Zobaczy Twoje zezwolenie i dzisiejsze ryby.'**
  String get controlScope;

  /// No description provided for @codeExpiredTitle.
  ///
  /// In pl, this message translates to:
  /// **'Kod wygasł'**
  String get codeExpiredTitle;

  /// No description provided for @regenerateCode.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż nowy kod'**
  String get regenerateCode;

  /// No description provided for @preparingCode.
  ///
  /// In pl, this message translates to:
  /// **'Najpierw wysyłam dzisiejsze ryby. Kod pojawi się za chwilę.'**
  String get preparingCode;

  /// No description provided for @reminders.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienia'**
  String get reminders;

  /// No description provided for @sevenDaysBefore.
  ///
  /// In pl, this message translates to:
  /// **'7 dni przed końcem'**
  String get sevenDaysBefore;

  /// No description provided for @oneDayBefore.
  ///
  /// In pl, this message translates to:
  /// **'1 dzień przed końcem'**
  String get oneDayBefore;

  /// No description provided for @reminderHour.
  ///
  /// In pl, this message translates to:
  /// **'Godzina'**
  String get reminderHour;

  /// No description provided for @reminderSaved.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia przypomnień zapisane'**
  String get reminderSaved;

  /// No description provided for @expiresToday.
  ///
  /// In pl, this message translates to:
  /// **'Zezwolenie wygasa dziś'**
  String get expiresToday;

  /// No description provided for @expiresInDays.
  ///
  /// In pl, this message translates to:
  /// **'{days, plural, one{Zezwolenie wygasa jutro} other{Zezwolenie wygasa za {days} dni}}'**
  String expiresInDays(int days);

  /// No description provided for @waterLevel.
  ///
  /// In pl, this message translates to:
  /// **'Poziom wody'**
  String get waterLevel;

  /// No description provided for @station.
  ///
  /// In pl, this message translates to:
  /// **'Parsęta · stacja przykładowa'**
  String get station;

  /// No description provided for @day.
  ///
  /// In pl, this message translates to:
  /// **'24 godz.'**
  String get day;

  /// No description provided for @week.
  ///
  /// In pl, this message translates to:
  /// **'7 dni'**
  String get week;

  /// No description provided for @month.
  ///
  /// In pl, this message translates to:
  /// **'30 dni'**
  String get month;

  /// No description provided for @readingTable.
  ///
  /// In pl, this message translates to:
  /// **'Odczyty w tabeli'**
  String get readingTable;

  /// No description provided for @measuredAt.
  ///
  /// In pl, this message translates to:
  /// **'Pomiar'**
  String get measuredAt;

  /// No description provided for @noReading.
  ///
  /// In pl, this message translates to:
  /// **'Brak pomiaru'**
  String get noReading;

  /// No description provided for @noRecordings.
  ///
  /// In pl, this message translates to:
  /// **'Brak dostępnych nagrań.'**
  String get noRecordings;

  /// No description provided for @fishMigration.
  ///
  /// In pl, this message translates to:
  /// **'Wędrówki ryb'**
  String get fishMigration;

  /// No description provided for @fishPass.
  ///
  /// In pl, this message translates to:
  /// **'Przepławka'**
  String get fishPass;

  /// No description provided for @recording.
  ///
  /// In pl, this message translates to:
  /// **'Nagranie'**
  String get recording;

  /// No description provided for @play.
  ///
  /// In pl, this message translates to:
  /// **'Odtwórz'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In pl, this message translates to:
  /// **'Pauza'**
  String get pause;

  /// No description provided for @readability.
  ///
  /// In pl, this message translates to:
  /// **'Czytelność'**
  String get readability;

  /// No description provided for @largeText.
  ///
  /// In pl, this message translates to:
  /// **'Większy tekst'**
  String get largeText;

  /// No description provided for @reduceMotion.
  ///
  /// In pl, this message translates to:
  /// **'Ogranicz animacje'**
  String get reduceMotion;

  /// No description provided for @help.
  ///
  /// In pl, this message translates to:
  /// **'Pomoc'**
  String get help;

  /// No description provided for @helpSteps.
  ///
  /// In pl, this message translates to:
  /// **'1. Zacznij dzień i wybierz miejsce.\n2. Dodaj każdą rybę, także wypuszczoną.\n3. Użyj przycisku „Zmień miejsce”, gdy przeniesiesz się nad wodą.\n4. Zakończ dzień, również bez połowu.'**
  String get helpSteps;

  /// No description provided for @simulateOffline.
  ///
  /// In pl, this message translates to:
  /// **'Symuluj brak internetu'**
  String get simulateOffline;

  /// No description provided for @failNextSync.
  ///
  /// In pl, this message translates to:
  /// **'Przetestuj błąd następnej wysyłki'**
  String get failNextSync;

  /// No description provided for @signOutQuestion.
  ///
  /// In pl, this message translates to:
  /// **'Wylogować się? Wpisy na urządzeniu zostaną zachowane.'**
  String get signOutQuestion;

  /// No description provided for @guardControl.
  ///
  /// In pl, this message translates to:
  /// **'Kontrola wędkarza'**
  String get guardControl;

  /// No description provided for @controlReference.
  ///
  /// In pl, this message translates to:
  /// **'Kod kontroli / odnośnik QR'**
  String get controlReference;

  /// No description provided for @checkCode.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź kod'**
  String get checkCode;

  /// No description provided for @currentSession.
  ///
  /// In pl, this message translates to:
  /// **'Bieżąca sesja'**
  String get currentSession;

  /// No description provided for @noCurrentSession.
  ///
  /// In pl, this message translates to:
  /// **'Brak bieżącej sesji'**
  String get noCurrentSession;

  /// No description provided for @refresh.
  ///
  /// In pl, this message translates to:
  /// **'Odśwież'**
  String get refresh;

  /// No description provided for @sessionEnded.
  ///
  /// In pl, this message translates to:
  /// **'Dzisiejszy połów zapisany.'**
  String get sessionEnded;

  /// No description provided for @copyCode.
  ///
  /// In pl, this message translates to:
  /// **'Kopiuj kod'**
  String get copyCode;

  /// No description provided for @copied.
  ///
  /// In pl, this message translates to:
  /// **'Skopiowano'**
  String get copied;

  /// No description provided for @menu.
  ///
  /// In pl, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @receivedShort.
  ///
  /// In pl, this message translates to:
  /// **'Wysłano'**
  String get receivedShort;

  /// No description provided for @pendingShort.
  ///
  /// In pl, this message translates to:
  /// **'Czeka'**
  String get pendingShort;

  /// No description provided for @sendFailedShort.
  ///
  /// In pl, this message translates to:
  /// **'Nie wysłano'**
  String get sendFailedShort;

  /// No description provided for @localOffline.
  ///
  /// In pl, this message translates to:
  /// **'Ryby są zapisane na telefonie.\nBez internetu działa tylko Rejestr.'**
  String get localOffline;

  /// No description provided for @localSaved.
  ///
  /// In pl, this message translates to:
  /// **'Wpisy są zapisane na telefonie.'**
  String get localSaved;

  /// No description provided for @todayAllPlaces.
  ///
  /// In pl, this message translates to:
  /// **'Dzisiaj, wszystkie miejsca'**
  String get todayAllPlaces;

  /// No description provided for @whereFishing.
  ///
  /// In pl, this message translates to:
  /// **'Gdzie teraz łowisz?'**
  String get whereFishing;

  /// No description provided for @newPlaceTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowe miejsce'**
  String get newPlaceTitle;

  /// No description provided for @fishHere.
  ///
  /// In pl, this message translates to:
  /// **'Łowię tutaj'**
  String get fishHere;

  /// No description provided for @placeChangeHint.
  ///
  /// In pl, this message translates to:
  /// **'Zmiana miejsca nie rusza ryb zapisanych wcześniej.'**
  String get placeChangeHint;

  /// No description provided for @chooseSpecies.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz gatunek'**
  String get chooseSpecies;

  /// No description provided for @whichSpecies.
  ///
  /// In pl, this message translates to:
  /// **'Jaka to ryba?'**
  String get whichSpecies;

  /// No description provided for @chooseSpeciesFirst.
  ///
  /// In pl, this message translates to:
  /// **'Najpierw wybierz gatunek.'**
  String get chooseSpeciesFirst;

  /// No description provided for @fatePrompt.
  ///
  /// In pl, this message translates to:
  /// **'Co z rybą?'**
  String get fatePrompt;

  /// No description provided for @saveCorrection.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz poprawkę'**
  String get saveCorrection;

  /// No description provided for @offlineCatch.
  ///
  /// In pl, this message translates to:
  /// **'Brak internetu. Ryba zapisze się na telefonie.'**
  String get offlineCatch;

  /// No description provided for @longest.
  ///
  /// In pl, this message translates to:
  /// **'Najdłuższe'**
  String get longest;

  /// No description provided for @heaviest.
  ///
  /// In pl, this message translates to:
  /// **'Najcięższe'**
  String get heaviest;

  /// No description provided for @recordsHint.
  ///
  /// In pl, this message translates to:
  /// **'Największa ryba każdego gatunku, także wypuszczona.'**
  String get recordsHint;

  /// No description provided for @previousRecord.
  ///
  /// In pl, this message translates to:
  /// **'Poprzedni'**
  String get previousRecord;

  /// No description provided for @dayEndedTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dzień zakończony'**
  String get dayEndedTitle;

  /// No description provided for @startNewDay.
  ///
  /// In pl, this message translates to:
  /// **'Zacznij nowy dzień'**
  String get startNewDay;

  /// No description provided for @keepFishing.
  ///
  /// In pl, this message translates to:
  /// **'Łowię dalej'**
  String get keepFishing;

  /// No description provided for @noFishToday.
  ///
  /// In pl, this message translates to:
  /// **'Dziś bez ryb'**
  String get noFishToday;

  /// No description provided for @endWithoutFish.
  ///
  /// In pl, this message translates to:
  /// **'Zakończ dzień bez ryb'**
  String get endWithoutFish;

  /// No description provided for @startDayHint.
  ///
  /// In pl, this message translates to:
  /// **'Zacznij dzień i wybierz miejsce. Ryby dopiszesz później.'**
  String get startDayHint;

  /// No description provided for @login.
  ///
  /// In pl, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @yourPhoto.
  ///
  /// In pl, this message translates to:
  /// **'Twoje zdjęcie'**
  String get yourPhoto;

  /// No description provided for @speciesCaption.
  ///
  /// In pl, this message translates to:
  /// **'Ilustracja gatunku. To nie jest zdjęcie Twojej ryby.'**
  String get speciesCaption;

  /// No description provided for @measurements.
  ///
  /// In pl, this message translates to:
  /// **'Pomiary'**
  String get measurements;

  /// No description provided for @anglerAccountLabel.
  ///
  /// In pl, this message translates to:
  /// **'konto wędkarza'**
  String get anglerAccountLabel;

  /// No description provided for @showPermit.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż zezwolenie'**
  String get showPermit;

  /// No description provided for @offlineCode.
  ///
  /// In pl, this message translates to:
  /// **'Kod działa tylko z internetem. Dzisiejsze ryby są zapisane na telefonie i możesz je pokazać strażnikowi w Rejestrze.'**
  String get offlineCode;

  /// No description provided for @correctionHint.
  ///
  /// In pl, this message translates to:
  /// **'Poprawka zmieni ten wpis. Nie doda nowej ryby.'**
  String get correctionHint;

  /// No description provided for @keepEntry.
  ///
  /// In pl, this message translates to:
  /// **'Zostaw wpis'**
  String get keepEntry;

  /// No description provided for @deleteHint.
  ///
  /// In pl, this message translates to:
  /// **'Ryba zniknie z rozliczenia i z rekordów.'**
  String get deleteHint;

  /// No description provided for @noFishDayHint.
  ///
  /// In pl, this message translates to:
  /// **'Taki dzień też się liczy. Zapiszemy sam dzień nad wodą.'**
  String get noFishDayHint;

  /// No description provided for @closeCode.
  ///
  /// In pl, this message translates to:
  /// **'Zamknij kod'**
  String get closeCode;

  /// No description provided for @permitPeriod.
  ///
  /// In pl, this message translates to:
  /// **'Okres'**
  String get permitPeriod;

  /// No description provided for @expiryDay.
  ///
  /// In pl, this message translates to:
  /// **'W dniu końca'**
  String get expiryDay;

  /// No description provided for @saveReminders.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz przypomnienia'**
  String get saveReminders;

  /// No description provided for @expiredCodeHint.
  ///
  /// In pl, this message translates to:
  /// **'Minęły 2 minuty. Zezwolenie i ryby są bez zmian.'**
  String get expiredCodeHint;

  /// No description provided for @placeCount.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, one{1 miejsce} few{{count} miejsca} other{{count} miejsc}}'**
  String placeCount(int count);

  /// No description provided for @fishCount.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, one{1 ryba} few{{count} ryby} other{{count} ryb}}'**
  String fishCount(int count);

  /// No description provided for @dayBalance.
  ///
  /// In pl, this message translates to:
  /// **'{released, plural, one{1 wypuszczona} few{{released} wypuszczone} other{{released} wypuszczonych}}, {retained, plural, one{1 zabrana} few{{retained} zabrane} other{{retained} zabranych}} ({mass})'**
  String dayBalance(int released, int retained, String mass);

  /// No description provided for @accounts.
  ///
  /// In pl, this message translates to:
  /// **'Konta'**
  String get accounts;

  /// No description provided for @salmon.
  ///
  /// In pl, this message translates to:
  /// **'Łosoś'**
  String get salmon;

  /// No description provided for @seaTrout.
  ///
  /// In pl, this message translates to:
  /// **'Troć wędrowna'**
  String get seaTrout;

  /// No description provided for @videoUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Nie można odtworzyć nagrania.'**
  String get videoUnavailable;

  /// No description provided for @section.
  ///
  /// In pl, this message translates to:
  /// **'Odcinek'**
  String get section;

  /// No description provided for @noMorePlaces.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie dostępne miejsca są już dodane.'**
  String get noMorePlaces;

  /// No description provided for @expiredOn.
  ///
  /// In pl, this message translates to:
  /// **'Wygasło'**
  String get expiredOn;

  /// No description provided for @placeNotChanged.
  ///
  /// In pl, this message translates to:
  /// **'Ryby z poprzednich miejsc zostają bez zmian.'**
  String get placeNotChanged;

  /// No description provided for @checkPurchase.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź ponownie'**
  String get checkPurchase;

  /// No description provided for @purchasePending.
  ///
  /// In pl, this message translates to:
  /// **'Czekamy na potwierdzenie Związku.'**
  String get purchasePending;

  /// No description provided for @purchasePendingHint.
  ///
  /// In pl, this message translates to:
  /// **'Zezwolenie pojawi się tutaj, gdy Związek potwierdzi zakup.'**
  String get purchasePendingHint;

  /// No description provided for @noExpiredPermits.
  ///
  /// In pl, this message translates to:
  /// **'Brak wygasłych zezwoleń'**
  String get noExpiredPermits;

  /// No description provided for @noPermitHint.
  ///
  /// In pl, this message translates to:
  /// **'Kupisz je na stronie Związku. Po zakupie wróć tutaj.'**
  String get noPermitHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
