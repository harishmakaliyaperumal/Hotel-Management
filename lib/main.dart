import 'package:flutter/material.dart';
import 'package:holtelmanagement/features/auth/screens/login.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'classes/ LanguageProvider.dart';
import 'classes/language.dart';
import 'common/helpers/shared_preferences_helper.dart';
import 'features/customer/user_menu.dart';
import 'features/dashboard/services/services_page_screens/servicedashboard.dart';
import 'features/kitchenMenu/screens/kitchendashboard.dart';
import 'l10n/app_localizations.dart';
// import 'common/helpers/token_provider.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences helper
  final prefsHelper = SharedPreferencesHelper();



  // Check authentication and get user type
  final loginData = await prefsHelper.getLoginData();
  String? initialRoute;

  if (loginData != null) {
    final userType = loginData['userType'];
    // final userName = loginData['username'];
    // final userId = loginData['id'];
    // final roomNo = int.tryParse(loginData['roomNo']?.toString() ?? '0') ?? 0;
    // final floorId = int.tryParse(loginData['floorId']?.toString() ?? '0') ?? 0;
    switch (userType) {
      case 'CUSTOMER':
        initialRoute = '/customer';
        break;
      case 'SERVICE':
        initialRoute = '/service';
        break;
      case 'RESTAURANT':
        initialRoute = '/restaurant';
        break;
      default:
        initialRoute = '/login';
    }
  } else {
    initialRoute = '/login';
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
      ],
      child: MyApp(
        initialRoute: initialRoute,
        loginData: loginData,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final Map<String, dynamic>? loginData;

  const MyApp({
    Key? key,
    required this.initialRoute,
    this.loginData,
  }) : super(key: key);

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
          initialRoute: initialRoute,
          onGenerateRoute: (settings) {
            // Helper function to extract login data
            Map<String, dynamic> getData() {
              return loginData ?? {};
            }

            switch (settings.name) {
              case '/login':
                return MaterialPageRoute(builder: (_) => const LoginPage());
              case '/customer':
                final data = getData();
                return MaterialPageRoute(
                  builder: (_) => UserMenu(
                    userName: data['username'],
                    userId: data['id'],
                    floorId: int.tryParse(data['floorId']?.toString() ?? '0') ?? 0,
                    roomNo: int.tryParse(data['roomNo']?.toString() ?? '0') ?? 0,
                    rname: data['username'],
                    hotelId: data['hotelId'],
                    loginResponse: data,
                  ),
                );
              case '/service':
                final data = getData();
                return MaterialPageRoute(
                  builder: (_) => ServicesDashboard(
                    userId: data['id'],
                    userName: data['username'],
                    roomNo: data['roomNo']?.toString() ?? '0',
                    floorId: data['floorId']?.toString() ?? '0',
                    hotelId: data['hotelId'],
                  ),
                );
              case '/restaurant':
                return MaterialPageRoute(builder: (_) => const KitchenDashboard());
              default:
                return MaterialPageRoute(builder: (_) => const LoginPage());
            }
          },
          builder: (context, child) {
            return Directionality(
              textDirection: languageProvider.isLTR()
                  ? TextDirection.ltr
                  : TextDirection.ltr,
              child: child!,
            );
          },
        );
      },
    );
  }
}
