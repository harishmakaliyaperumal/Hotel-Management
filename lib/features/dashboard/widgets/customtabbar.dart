import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../common/widgets/custom_tab_button.dart';


class CustomTabBar extends StatelessWidget {
  final TabController tabController;
  final int availableRequestsCount;
  final int completedRequestsCount;
  final Function(int) onTabChanged;

  const CustomTabBar({
    Key? key,
    required this.tabController,
    required this.availableRequestsCount,
    required this.completedRequestsCount,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          CustomTabButton(
            label: AppLocalizations.of(context).translate('ser_pg_tap_text_available'),
            icon: Icons.pending_actions,
            isSelected: tabController.index == 0,
            onTap: () => onTabChanged(0),
            count: availableRequestsCount,
          ),
          // CustomTabButton(
          //   label: AppLocalizations.of(context).translate('ser_pg_tap_text_completed'),
          //   icon: Icons.task_alt,
          //   isSelected: tabController.index == 1,
          //   onTap: () => onTabChanged(1),
          //   count: completedRequestsCount,
          // ),
        ],
      ),
    );
  }
}