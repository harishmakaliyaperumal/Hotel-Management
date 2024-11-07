import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_theme.dart';

AppBar buildAppBar( BuildContext context,String userName,VoidCallback onLogoutPressed ,{List<Widget>? extraActions}){
  return AppBar(
    backgroundColor: AppColors.HPrimaryColor,
    title: Row(
      children: [
        // Add the logo image on the left
        Container(
          margin: const EdgeInsets.only(right: 8.0), // Space between logo and username
          child: Image.asset(
            'assets/images/logo.png', // Updated path to match pubspec.yaml
            height: MediaQuery.of(context).size.height * 0.05, // Responsive height
            width: MediaQuery.of(context).size.height * 0.04,
            fit: BoxFit.cover,
          ),
        ),
        // Display the username
        Text(
          userName,
          style: AppTextTheme.HAppBarStyle.copyWith(
            fontSize: 24, // Adjusted font size
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    ),

    actions: [
      // Add extra actions (e.g., the "break" icon)
      if (extraActions != null) ...extraActions,

      // Default Logout Icon
      IconButton(
        icon: const Icon(Icons.logout), // Logout icon
        onPressed: onLogoutPressed,
        color: Colors.white,
      ),
    ],
  );

}