import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum FloodStatus {
  normal,
  advisory,
  warning,
  critical,
}

class StatusBadge extends StatelessWidget {
  final FloodStatus status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  Color get statusColor {
    switch (status) {
      case FloodStatus.normal:
        return AppColors.normal;

      case FloodStatus.advisory:
        return AppColors.advisory;

      case FloodStatus.warning:
        return AppColors.warning;

      case FloodStatus.critical:
        return AppColors.critical;
    }
  }

  String get statusText {
    switch (status) {
      case FloodStatus.normal:
        return 'NORMAL';

      case FloodStatus.advisory:
        return 'ADVISORY';

      case FloodStatus.warning:
        return 'WARNING';

      case FloodStatus.critical:
        return 'CRITICAL';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}