import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/colors.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback toggleVisibility;

  const PasswordField({
    Key? key,
    required this.controller,
    required this.obscureText,
    required this.toggleVisibility,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock, color: Colors.black),
        hintText: AppLocalizations.of(context).translate('login_pg_form_filed_userPassword'),
        hintStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: AppColors.backgroundColor,
            width: 1.5,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off, color: Colors.black),
          onPressed: toggleVisibility,
        ),
      ),
      // Add validation logic here
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).translate('login_form_field_error_empty_password');
        }
        // if (value.length < 8) {
        //   return AppLocalizations.of(context).translate('error_password_too_short');
        // }
        // // Optional: Check for a mix of characters
        // final passwordPattern = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$';
        // final regex = RegExp(passwordPattern);

        // if (!regex.hasMatch(value)) {
        //   return AppLocalizations.of(context).translate('error_password_criteria');
        // }

        return null; // Return null if the password is valid
      },
    );
  }
}