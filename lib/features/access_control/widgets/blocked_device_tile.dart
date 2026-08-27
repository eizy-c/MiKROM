import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../dashboard/models/device_model.dart';

/// Tile representing a blocked host with 1-tap unblock action.
class BlockedDeviceTile extends StatelessWidget {
  final DeviceModel device;
  final VoidCallback onUnblock;

  const BlockedDeviceTile({
    super.key,
    required this.device,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.statusDangerBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.statusDanger.withValues(alpha: 0.2)),
            ),
            child: const Icon(
              Icons.block_outlined,
              color: AppColors.statusDanger,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.displayName,
                  style: AppTypography.bodyBold.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.fingerprint_outlined,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      device.mac,
                      style: AppTypography.monoCodeSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (device.ip != '0.0.0.0') ...[
                  const SizedBox(height: 2),
                  Text(
                    'Última IP: ${device.ip}',
                    style: AppTypography.caption.copyWith(fontSize: 10),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.statusSuccess,
              side: const BorderSide(color: AppColors.statusSuccess),
              minimumSize: const Size(100, 36),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.lock_open_outlined, size: 16),
            label: Text(
              'Desbloquear',
              style: AppTypography.chipText.copyWith(
                color: AppColors.statusSuccess,
                fontSize: 11,
              ),
            ),
            onPressed: onUnblock,
          ),
        ],
      ),
    );
  }
}
