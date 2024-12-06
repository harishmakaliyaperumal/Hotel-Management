// lib/features/authentication/widgets/login_button.dart

import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/colors.dart';
import '../../../common/widgets/custom_button.dart';


class LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const LoginButton({Key? key, required this.isLoading, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.textColor))
        : Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.backgroundColor,
      ),
      child: CustomButton(
        text: (          AppLocalizations.of(context).translate('loing_bttn_text')),
        onPressed: onPressed,
        isLoading: isLoading,
      ),
    );
  }
}
