import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../models/network_stats_model.dart';

/// Traffic and devices summary card for dashboard.
class TrafficSummaryCard extends StatelessWidget {
  final NetworkStatsModel stats;

  const TrafficSummaryCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Dispositivos Activos',
                  value: '${stats.activeDevicesCount}',
                  subtitle: 'de ${stats.totalDevicesCount} conocidos',
                  icon: Icons.devices_outlined,
                  iconColor: AppColors.statusSuccess,
                  iconBgColor: AppColors.statusSuccessBg,
                ),
              ),
              Container(
                height: 50,
                width: 1,
                color: AppColors.divider,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: _buildMetricTile(
                  title: 'Bloqueados',
                  value: '${stats.blockedDevicesCount}',
                  subtitle: 'acceso restringido',
                  icon: Icons.block_outlined,
                  iconColor: stats.blockedDevicesCount > 0
                      ? AppColors.statusDanger
                      : AppColors.textMuted,
                  iconBgColor: stats.blockedDevicesCount > 0
                      ? AppColors.statusDangerBg
                      : AppColors.statusNeutralBg,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSpeedItem(
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.secondary,
                  label: 'Bajada',
                  speed: Formatters.formatSpeed(stats.downloadSpeedMbps),
                ),
                Container(height: 24, width: 1, color: AppColors.divider),
                _buildSpeedItem(
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.primary,
                  label: 'Subida',
                  speed: Formatters.formatSpeed(stats.uploadSpeedMbps),
                ),
                Container(height: 24, width: 1, color: AppColors.divider),
                _buildSpeedItem(
                  icon: Icons.wifi_channel_outlined,
                  color: AppColors.statusWarning,
                  label: 'Canal',
                  speed: 'CH ${stats.channel} (${stats.frequencyBand.split(' ').first})',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.caption.copyWith(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: AppTypography.displayTitle.copyWith(
                  fontSize: 18,
                  height: 1.1,
                ),
              ),
              Text(
                subtitle,
                style: AppTypography.caption.copyWith(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedItem({
    required IconData icon,
    required Color color,
    required String label,
    required String speed,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
            Text(
              speed,
              style: AppTypography.monoCodeSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
