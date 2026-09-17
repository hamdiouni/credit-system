import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  late Locale _currentLocale;
  
  static const String _languageKey = 'app_language';
  
  Locale get currentLocale => _currentLocale;
  
  String get languageCode => _currentLocale.languageCode;

  final List<Locale> supportedLocales = const [
    Locale('en'),
    Locale('ar'),
    Locale('fr'),
    Locale('tn'), // Tunisian Arabic (Derja)
  ];

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final savedLanguage = _prefs?.getString(_languageKey);
      
      if (savedLanguage != null && savedLanguage.isNotEmpty) {
        _currentLocale = Locale(savedLanguage);
      } else {
        // Get device locale
        try {
          final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
          if (supportedLocales.contains(deviceLocale)) {
            _currentLocale = deviceLocale;
          } else {
            _currentLocale = const Locale('en');
          }
        } catch (e) {
          print('⚠️ [LocalizationProvider] Error getting device locale: $e');
          _currentLocale = const Locale('en');
        }
      }
      notifyListeners();
    } catch (e) {
      print('❌ [LocalizationProvider] Initialization error: $e');
      // Default to English on error
      _currentLocale = const Locale('en');
      // Don't set _prefs if initialization failed
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    
    _currentLocale = locale;
    
    // Only save to SharedPreferences if it's initialized
    try {
      if (_prefs != null) {
        await _prefs!.setString(_languageKey, locale.languageCode);
      } else {
        // Try to initialize SharedPreferences if not already done
        _prefs = await SharedPreferences.getInstance();
        await _prefs!.setString(_languageKey, locale.languageCode);
      }
    } catch (e) {
      print('⚠️ [LocalizationProvider] Could not save language preference: $e');
      // Continue anyway - language change will work for current session
    }
    
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    await setLocale(Locale(languageCode));
  }
}
