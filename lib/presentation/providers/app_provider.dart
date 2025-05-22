import 'package:flutter/material.dart';
import 'package:travel_manager/services/local_storage_service.dart';

class AppProvider extends ChangeNotifier {
  final LocalStorageService _localStorageService;
  
  // App settings
  ThemeMode _themeMode;
  Locale _locale;
  
  AppProvider(this._localStorageService) :
    _themeMode = _localStorageService.getThemeMode(),
    _locale = Locale(_localStorageService.getLanguageCode(), '');
  
  // Theme mode
  ThemeMode get themeMode => _themeMode;
  
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    await _localStorageService.setThemeMode(mode);
    notifyListeners();
  }
  
  // Locale
  Locale get locale => _locale;
  
  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode == locale.languageCode) return;
    
    _locale = locale;
    await _localStorageService.setLanguageCode(locale.languageCode);
    notifyListeners();
  }
  
  // Helper methods for setting locale by language code
  Future<void> setLanguage(String languageCode) async {
    await setLocale(Locale(languageCode, ''));
  }
} 