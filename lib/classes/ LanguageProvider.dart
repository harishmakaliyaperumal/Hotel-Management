import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../classes/language.dart';

class LanguageProvider extends ChangeNotifier {
  Language _currentLanguage = Language.languageList().first;
  Locale? _currentLocale;
  static const String LANGUAGE_CODE_KEY = 'language_code';

  Language get currentLanguage => _currentLanguage;
  Locale get currentLocale => _currentLocale ?? Locale(_currentLanguage.languageCode);


  Future<void> initLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString(LANGUAGE_CODE_KEY);
    if (savedLanguageCode != null) {
      _currentLanguage = Language.languageList().firstWhere(
            (lang) => lang.languageCode == savedLanguageCode,
        orElse: () => Language.languageList().first,
      );
      _currentLocale = Locale(_currentLanguage.languageCode);
      notifyListeners();
    }
  }

  Future<void> changeLanguage(Language newLanguage) async {
    if (_currentLanguage != newLanguage) {
      _currentLanguage = newLanguage;
      _currentLocale = Locale(newLanguage.languageCode);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(LANGUAGE_CODE_KEY, newLanguage.languageCode);

      notifyListeners();
    }
  }

  bool isLTR() {
    return _currentLanguage.languageCode == 'ar';
  }
}