import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  // Common strings
  String get appName;
  String get close;
  String get cancel;
  String get confirm;
  String get save;
  String get delete;
  String get edit;
  String get add;
  String get search;
  String get filter;
  String get sort;
  String get loading;
  String get error;
  String get retry;
  String get success;
  String get warning;
  String get info;
  String get yes;
  String get no;
  String get ok;
  String get back;
  String get next;
  String get previous;
  String get done;
  String get skip;
  String get selectAll;
  String get deselectAll;
  String get noDataFound;
  String get noResultsFound;
  String get tryAgain;
  String get refresh;
  
  // Authentication
  String get welcome;
  String get login;
  String get logout;
  String get register;
  String get email;
  String get password;
  String get confirmPassword;
  String get forgotPassword;
  String get resetPassword;
  String get createAccount;
  String get alreadyHaveAccount;
  String get dontHaveAccount;
  String get invalidEmail;
  String get invalidPassword;
  String get passwordsDoNotMatch;
  String get loginFailed;
  String get registrationFailed;
  String get resetPasswordSent;
  
  // Onboarding
  String get onboardingTitle1;
  String get onboardingDescription1;
  String get onboardingTitle2;
  String get onboardingDescription2;
  String get onboardingTitle3;
  String get onboardingDescription3;
  String get getStarted;
  
  // Wardrobe
  String get wardrobe;
  String get myWardrobe;
  String get addClothingItem;
  String get clothingItem;
  String get clothingItems;
  String get category;
  String get categories;
  String get color;
  String get colors;
  String get brand;
  String get size;
  String get condition;
  String get purchaseDate;
  String get purchasePrice;
  String get notes;
  String get favorite;
  String get favorites;
  String get addToFavorites;
  String get removeFromFavorites;
  String get selectPhoto;
  String get takePhoto;
  String get chooseFromGallery;
  String get itemAddedSuccessfully;
  String get itemUpdatedSuccessfully;
  String get itemDeletedSuccessfully;
  String get deleteItemConfirmation;
  String get deleteItem;
  
  // Categories
  String get tops;
  String get bottoms;
  String get dresses;
  String get outerwear;
  String get shoes;
  String get accessories;
  String get underwear;
  String get sleepwear;
  String get activewear;
  String get formal;
  String get casual;
  String get work;
  
  // Colors
  String get black;
  String get white;
  String get gray;
  String get brown;
  String get beige;
  String get red;
  String get pink;
  String get orange;
  String get yellow;
  String get green;
  String get blue;
  String get purple;
  String get navy;
  String get multicolor;
  
  // Conditions
  String get excellent;
  String get good;
  String get fair;
  String get poor;
  
  // Outfits
  String get outfits;
  String get myOutfits;
  String get createOutfit;
  String get outfitName;
  String get outfitCreated;
  String get outfitUpdated;
  String get outfitDeleted;
  String get deleteOutfitConfirmation;
  String get selectItems;
  String get noItemsSelected;
  String get outfit;
  
  // Settings
  String get settings;
  String get profile;
  String get preferences;
  String get language;
  String get theme;
  String get darkMode;
  String get lightMode;
  String get systemMode;
  String get notifications;
  String get privacy;
  String get about;
  String get version;
  String get support;
  String get contactUs;
  String get rateApp;
  String get shareApp;
  String get clearCache;
  String get clearData;
  String get exportData;
  String get importData;
  
  // Errors
  String get somethingWentWrong;
  String get networkError;
  String get noInternetConnection;
  String get serverError;
  String get dataLoadingFailed;
  String get dataSavingFailed;
  String get validationError;
  String get permissionDenied;
  String get fileNotFound;
  String get invalidFile;
  String get uploadFailed;
  
  // Date and Time
  String get today;
  String get yesterday;
  String get tomorrow;
  String get thisWeek;
  String get lastWeek;
  String get thisMonth;
  String get lastMonth;
  String get thisYear;
  String get lastYear;
  
  // Statistics
  String get statistics;
  String get totalItems;
  String get totalOutfits;
  String get favoriteItems;
  String get recentlyAdded;
  String get mostWorn;
  String get leastWorn;
  String get averagePrice;
  String get totalValue;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'tr': return AppLocalizationsTr();
  }
  throw FlutterError('AppLocalizations.delegate failed to load unsupported locale "$locale". '
      'This is likely an issue with the localizations generation tool. '
      'Supported locales: ${AppLocalizations.supportedLocales}');
}
