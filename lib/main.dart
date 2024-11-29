import 'package:flutter/material.dart';
import 'package:holtelmanagement/features/auth/screens/login.dart';
import 'package:holtelmanagement/features/dashboard/screens/users_page_screens/food_menu/food_products/food_product_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'classes/ LanguageProvider.dart';
import 'classes/language.dart';
// import 'features/auth/screens/login.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: Locale(languageProvider.currentLanguage.languageCode),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: Language.languageList()
              .map((lang) => Locale(lang.languageCode))
              .toList(),
          builder: (context, child) {
            return Directionality(
              textDirection: languageProvider.isLTR()
                  ? TextDirection.ltr
                  : TextDirection.ltr,
              child: child!,
            );
          },
          home: const LoginPage(),
        );
      },
    );
  }
}
