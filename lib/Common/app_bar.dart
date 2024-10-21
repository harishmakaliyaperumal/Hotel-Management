import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_theme.dart';

AppBar buildAppBar( String userName,VoidCallback onLogoutPressed ,{List<Widget>? extraActions}){
  return AppBar(
    backgroundColor: AppColors.HPrimaryColor,
    title: Text(
      userName,
      style: AppTextTheme.HAppBarStyle.copyWith(
        fontSize: 24, // Using ScreenUtil for responsive font size
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ), ),

    actions: [
      // Add extra actions (e.g., the "break" icon)
      if (extraActions != null) ...extraActions,

      // Default Logout Icon
      IconButton(
        icon: Icon(Icons.logout), // Logout icon
        onPressed: onLogoutPressed,
        color: Colors.white,
      ),
    ],
  );

}