// lib/features/authentication/widgets/password_field.dart

import 'package:flutter/material.dart';
import 'package:holtelmanagement/l10n/app_localizations.dart';
import 'package:holtelmanagement/theme/colors.dart';


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
        hintStyle: const TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
              color: AppColors.backgroundColor,
              width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off, color: Colors.black),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }
}
