import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:hotel_trips/theme/colors.dart';

import 'colors.dart';

class AppTextTheme{
  static TextStyle HAppBarStyle = GoogleFonts.inter(
    color: AppColors.Hwhite,
    fontWeight: FontWeight.w600,
    fontSize: 26,
  );

  static TextStyle kPrimaryStyle = GoogleFonts.inter(
    color: AppColors.kSecondaryColor,
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );
  static TextStyle khintStyle = GoogleFonts.poppins(
    color: const Color(0xFFA9A9B7),
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );


  static TextStyle kLabelStyle = GoogleFonts.inter(
    color: AppColors.kSecondaryColor,
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );
}