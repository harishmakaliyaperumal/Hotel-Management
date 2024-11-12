import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Common/app_bar.dart';
import 'classes/language.dart';
import 'features/auth/login.dart';
import 'l10n/app_localizations.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Language _selectedLanguage = Language.languageList()[0];
  Locale _locale = const Locale('en'); // Default locale

  void _changeLocale(Language language) {
    setState(() {
      _selectedLanguage = language;
      _loadLocale();
      _locale = Locale(language.languageCode);
    });
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      locale: _locale,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
        Locale('no'), // Norwegian
      ],
      home: Scaffold(
        appBar: buildAppBar(
          context,
          _selectedLanguage,
          _changeLocale, extraActions: [], isLoginPage: true,
          // _logout,
        ),
        body: const LoginPage(),
      ),
    );
  }
}
