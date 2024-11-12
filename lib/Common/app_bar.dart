import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/language.dart';
import '../features/auth/login.dart';
import '../theme/colors.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    String languageCode = Localizations.localeOf(context).languageCode;
    String language = languageCode == 'en' ? 'English' : 'Norwegian';

    return AppBar(
      title: Text('App - $language'),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

AppBar buildAppBar(
    BuildContext context,
    Language selectedLanguage,
    Function(Language) onLanguageChange,
    {required bool isLoginPage, required List<Widget> extraActions}
    ) {
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout Confirmation'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () async {
                // Save the selected language code to SharedPreferences before logging out
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('language_code', selectedLanguage.languageCode);

                // Navigate to login page, clearing the navigation stack
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                      (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  return AppBar(
    backgroundColor: AppColors.whiteColor,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (!isLoginPage)
          Image.asset(
            'assets/images/logo.png',
            height: 40,
          ),
        Row(
          children: [
            DropdownButton<Language>(
              value: selectedLanguage,
              onChanged: (Language? newLanguage) {
                if (newLanguage != null) {
                  onLanguageChange(newLanguage);
                }
              },
              items: Language.languageList()
                  .map((Language language) => DropdownMenuItem<Language>(
                value: language,
                child: Text(
                  language.name,
                  style: const TextStyle(color: Colors.black),
                ),
              ))
                  .toList(),
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
            ),
            if (!isLoginPage)
              // PopupMenuButton<String>(
              //   icon: const Icon(Icons.menu, color: Colors.black),
              //   itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              //     PopupMenuItem<String>(
              //       value: 'settings',
              //       child: ListTile(
              //         leading: const Icon(Icons.settings),
              //         title: const Text('Settings'),
              //       ),
              //     ),
              //     const PopupMenuDivider(),
              //     PopupMenuItem<String>(
              //       value: 'logout',
              //       child: ListTile(
              //         leading: const Icon(Icons.logout),
              //         title: const Text('Logout'),
              //       ),
              //     ),
              //   ],
              //   onSelected: (String value) {
              //     if (value == 'logout') _handleLogout();
              //   },
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   color: Colors.white,
              //   elevation: 4,
              // ),
            ...extraActions,
          ],
        ),
      ],
    ),
    elevation: 4.0,
  );
}
