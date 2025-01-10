// lib/features/authentication/widgets/email_field.dart

import 'package:flutter/material.dart';
import 'package:holtelmanagement/l10n/app_localizations.dart';
import 'package:holtelmanagement/theme/colors.dart';



class EmailField extends StatelessWidget {
  final TextEditingController controller;

  const EmailField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: const Icon(
            Icons.supervised_user_circle_outlined, color: Colors.black),
        hintText: AppLocalizations.of(context).translate(
            'login_pg_form_filed_userEmailId'),
        hintStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
              color: AppColors.backgroundColor, width: 1.5),
        ),
      ),
      // Email Validation
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).translate('login_form_field_error_empty_email');
        }
        final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
        if (!emailRegex.hasMatch(value)) {
          return AppLocalizations.of(context).translate('error_invalid_email');
        }
        return null;
      },

    );
  }
}
