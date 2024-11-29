import 'package:flutter/material.dart';

import '../../theme/colors.dart';


class CustomTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final int count;

  const CustomTabButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.backgroundColor
                : AppColors.whiteColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black,
              ),
              const SizedBox(width: 8),
              Text(
                '$label ($count)',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}