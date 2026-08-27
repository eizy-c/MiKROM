import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

enum StatusBadgeType { online, offline, blocked, warning }

/// Clean pill badge to display router/device connection states.
/// Strictly no emojis: uses subtle color dot or icon.
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeType type;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusBadgeType.online,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final (Color bgColor, Color textColor, Color dotColor) = switch (type) {
      StatusBadgeType.online => (
          AppColors.statusSuccessBg,
          AppColors.statusSuccess,
          AppColors.statusSuccess
        ),
      StatusBadgeType.blocked => (
          AppColors.statusDangerBg,
          AppColors.statusDanger,
          AppColors.statusDanger
        ),
      StatusBadgeType.warning => (
          AppColors.statusWarningBg,
          AppColors.statusWarning,
          AppColors.statusWarning
        ),
      StatusBadgeType.offline => (
          AppColors.statusNeutralBg,
          AppColors.statusNeutral,
          AppColors.statusNeutral
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dotColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTypography.chipText.copyWith(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
