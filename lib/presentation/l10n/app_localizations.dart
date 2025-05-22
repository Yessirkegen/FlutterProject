import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_manager/presentation/l10n/translations/en_translations.dart';
import 'package:travel_manager/presentation/l10n/translations/ru_translations.dart';
import 'package:travel_manager/presentation/l10n/translations/kk_translations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': enTranslations,
    'ru': ruTranslations,
    'kk': kkTranslations,
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Helper function for readability
  String get appTitle => translate('app_title');
  String get homeTitle => translate('home_title');
  String get aboutTitle => translate('about_title');
  String get settingsTitle => translate('settings_title');
  String get profileTitle => translate('profile_title');
  String get historyTitle => translate('history_title');
  
  String get loginTitle => translate('login_title');
  String get registerTitle => translate('register_title');
  String get email => translate('email');
  String get password => translate('password');
  String get login => translate('login');
  String get register => translate('register');
  String get forgotPassword => translate('forgot_password');
  String get continueAsGuest => translate('continue_as_guest');
  String get guestMode => translate('guest_mode');
  String get guestModeMessage => translate('guest_mode_message');
  
  String get darkTheme => translate('dark_theme');
  String get lightTheme => translate('light_theme');
  String get systemTheme => translate('system_theme');
  String get language => translate('language');
  String get english => translate('english');
  String get russian => translate('russian');
  String get kazakh => translate('kazakh');
  
  String get addTrip => translate('add_trip');
  String get editTrip => translate('edit_trip');
  String get deleteTrip => translate('delete_trip');
  String get tripName => translate('trip_name');
  String get destination => translate('destination');
  String get startDate => translate('start_date');
  String get endDate => translate('end_date');
  String get budget => translate('budget');
  String get notes => translate('notes');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get required => translate('required');
  String get startDateRequired => translate('start_date_required');
  String get endDateRequired => translate('end_date_required');
  String get deleteConfirmation => translate('delete_confirmation');
  
  String get searchPlaceholder => translate('search_placeholder');
  String get filterByDate => translate('filter_by_date');
  String get filterByCountry => translate('filter_by_country');
  String get noTripsFound => translate('no_trips_found');
  String get noInternet => translate('no_internet');
  String get offline => translate('offline');
  String get sync => translate('sync');
  
  String get errorOccurred => translate('error_occurred');
  String get logoutConfirmation => translate('logout_confirmation');
  String get yes => translate('yes');
  String get no => translate('no');
  String get logout => translate('logout');
  
  // Profile screen
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get statistics => translate('statistics');
  String get totalTrips => translate('total_trips');
  String get notLoggedIn => translate('not_logged_in');
  String get theme => translate('theme');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ru', 'kk'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
} 