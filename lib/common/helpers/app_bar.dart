import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../classes/ LanguageProvider.dart';
// import '../classes/LanguageProvider.dart';
import '../../classes/language.dart';
import '../../features/auth/screens/login.dart';
import '../../features/dashboard/services/services_page_screens/breakhistory.dart';
import '../../features/dashboard/services/services_page_screens/ser_request_history.dart';
import '../../features/services/apiservices.dart';
import '../../theme/colors.dart';


enum DashboardType {
  services,
  user,
  other
}





Future<void> logOut(BuildContext context) async {
  try {
    // Clear SharedPreferences data
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navigate to the login page and remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
    );
    print("Navigated to login page"); // Verify navigation
  } catch (e) {
    // Show error if logout fails
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error during logout: $e'),
      ),
    );
  }
}




Future<void> clearUserData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  // Add any other user data cleanup logic here
}

// final int userId;

AppBar buildAppBar({
  required BuildContext context,
  required Function(Language) onLanguageChange,
  required bool isLoginPage,
  required List<Widget> extraActions,
  required DashboardType dashboardType,
  required VoidCallback onLogout,
  required ApiService apiService,
  VoidCallback? onLogoTap,



}) {

  Future<void> handleBreakNotification() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Get userId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final hotelId = prefs.getInt('hotelId');

      if (hotelId == null) {
        throw Exception('User ID not found');
      }

      // Make the API call
      await apiService.notifyBreaks(hotelId);

      // Close loading indicator
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Break notification sent successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Close loading indicator if it's showing
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send break notification: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }


  return AppBar(

    backgroundColor: isLoginPage ? Colors.transparent : AppColors.whiteColor,
    elevation: isLoginPage ? 0 : 4.0,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (!isLoginPage)
          GestureDetector( // Wrap the Image with GestureDetector
            onTap: onLogoTap, // Add the onTap handler
            child: MouseRegion( // Add MouseRegion for better UX on web
              cursor: SystemMouseCursors.click,
              child: Image.asset(
                'assets/images/logo.png',
                height: 40,
              ),
            ),
          ),

        if (!isLoginPage)
          PopupMenuButton(
            icon: Icon(
              Icons.menu,
              color: isLoginPage ? AppColors.whiteColor : Colors.black,
            ),
            itemBuilder: (BuildContext context) {
              List<PopupMenuEntry> menuItems = [
                PopupMenuItem(
                  child: Consumer<LanguageProvider>(
                    builder: (context, languageProvider, child) {
                      return DropdownButton<Language>(
                        value: languageProvider.currentLanguage,
                        onChanged: (Language? newLanguage) async {
                          if (newLanguage != null) {
                            await languageProvider.changeLanguage(newLanguage);
                            onLanguageChange(newLanguage);
                            Navigator.pop(context);
                          }
                        },
                        items: Language.languageList()
                            .map((language) => DropdownMenuItem(
                          value: language,
                          child: Text(language.name),
                        ))
                            .toList(),
                        underline: Container(),
                      );
                    },
                  ),
                ),

                if (dashboardType == DashboardType.services) ...[
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.history),
                      title: Text('Break History'),
                      onTap: () {
                        // var userId;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>  BreakHistory(userId: 0, // Pass the userId
                              userName: '', // Pass the userName
                              hotelId: 0,),
                          ),
                        );
                      },
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    child: ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Break Notify'),
                    onTap: () async {
                     Navigator.pop(context); // Close the menu first
                    await handleBreakNotification();
                  },
                   ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.history),
                      title: Text('Services History'),
                      onTap: () {
                        var userId;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>  SerRequestHistory(userId: 0, // Pass the userId
                              userName: '', // Pass the userName
                              hotelId: 0,),
                          ),
                        );
                      },
                    ),
                  ),

                ],


                const PopupMenuDivider(),
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () async {
                      Navigator.pop(context); // Close the popup menu first
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Logout Confirmation'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false), // Stay logged in
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red, // Set text color to red
                                ),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true), // Confirm logout
                                style: TextButton.styleFrom(
                                 backgroundColor: Color(0xff013457),
                                  foregroundColor:Colors.white,
                                  // Set text color to red
                                ),
                                child: const Text('Ok'),

                              ),
                            ],
                          );
                        },
                      );

                      if (shouldLogout == true) {
                        await clearUserData(); // Ensure data is cleared
                        onLogout(); // Call onLogout callback
                      }
                    },
                  ),
                ),


              ];

              return menuItems;
            },
          ),

        if (isLoginPage)
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: isLoginPage
                      ? AppColors.backgroundColor
                      : AppColors.whiteColor,
                ),
                child: DropdownButton(
                  value: languageProvider.currentLanguage,
                  onChanged: (Language? newLanguage) async {
                    if (newLanguage != null) {
                      await languageProvider.changeLanguage(newLanguage);
                      onLanguageChange(newLanguage);
                    }
                  },
                  items: Language.languageList()
                      .map((Language language) => DropdownMenuItem(
                    value: language,
                    child: Text(
                      language.name,
                      style: TextStyle(
                        color: isLoginPage
                            ? AppColors.whiteColor
                            : Colors.black,
                      ),
                    ),
                  ))
                      .toList(),
                  underline: Container(),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: isLoginPage ? AppColors.whiteColor : Colors.black,
                  ),
                  dropdownColor: isLoginPage
                      ? AppColors.backgroundColor
                      : AppColors.whiteColor,
                ),
              );
            },
          ),
        ...extraActions,
      ],
    ),
  );
}