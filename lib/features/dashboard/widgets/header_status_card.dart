import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/status_badge.dart';

/// Top header card showing active SSID, live status badge and quick scan trigger.
class HeaderStatusCard extends StatelessWidget {
  final String ssid;
  final bool isOnline;
  final bool isScanning;
  final VoidCallback onScanPressed;
  final VoidCallback onServerConfigPressed;

  const HeaderStatusCard({
    super.key,
    required this.ssid,
    required this.isOnline,
    required this.isScanning,
    required this.onScanPressed,
    required this.onServerConfigPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.router_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            ssid,
                            style: AppTypography.sectionHeader.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(
                          label: isOnline ? 'En línea' : 'Desconectado',
                          type: isOnline
                              ? StatusBadgeType.online
                              : StatusBadgeType.offline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Red Wi-Fi Local Principal',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 20),
                tooltip: 'Configuración de Host',
                color: AppColors.textSecondary,
                onPressed: onServerConfigPressed,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Topología de Red Activa',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              InkWell(
                onTap: isScanning ? null : onScanPressed,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isScanning
                        ? AppColors.cardBorder.withValues(alpha: 0.5)
                        : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isScanning)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      else
                        const Icon(
                          Icons.radar_outlined,
                          size: 15,
                          color: AppColors.primary,
                        ),
                      const SizedBox(width: 6),
                      Text(
                        isScanning ? 'Escaneando...' : 'Escanear Red',
                        style: AppTypography.chipText.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
