import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/device_model.dart';

enum DeviceMenuAction { viewDetails, renameAlias, limitBandwidth, assignStaticIp }

/// Device tile card showing host details, MAC chip, block switch and context menu.
class DeviceCard extends StatelessWidget {
  final DeviceModel device;
  final ValueChanged<bool> onBlockToggle;
  final VoidCallback onViewDetails;
  final VoidCallback onRenameAlias;
  final VoidCallback onLimitBandwidth;
  final VoidCallback onAssignStaticIp;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onBlockToggle,
    required this.onViewDetails,
    required this.onRenameAlias,
    required this.onLimitBandwidth,
    required this.onAssignStaticIp,
  });

  @override
  Widget build(BuildContext context) {
    final isBlocked = device.isBlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isBlocked ? const Color(0xFFFEF2F2) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBlocked
              ? AppColors.statusDanger.withValues(alpha: 0.3)
              : AppColors.cardBorder,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onViewDetails,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Host Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isBlocked
                            ? AppColors.statusDangerBg
                            : AppColors.scaffoldBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isBlocked
                              ? AppColors.statusDanger.withValues(alpha: 0.2)
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Icon(
                        device.iconData,
                        color: isBlocked
                            ? AppColors.statusDanger
                            : AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Names & IP
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  device.displayName,
                                  style: AppTypography.bodyBold.copyWith(
                                    fontSize: 14,
                                    color: isBlocked
                                        ? AppColors.statusDanger
                                        : AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (device.isStaticIp) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'IP FIJA',
                                    style: AppTypography.chipText.copyWith(
                                      fontSize: 9,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                device.ip,
                                style: AppTypography.monoCodeSmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  color: AppColors.textMuted,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                device.band,
                                style: AppTypography.caption.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Quick Block Switch
                    Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: !isBlocked,
                        activeThumbColor: AppColors.statusSuccess,
                        activeTrackColor: AppColors.statusSuccessBg,
                        inactiveThumbColor: AppColors.statusDanger,
                        inactiveTrackColor: AppColors.statusDangerBg,
                        onChanged: (active) {
                          onBlockToggle(!active);
                        },
                      ),
                    ),
                    // Context Menu
                    PopupMenuButton<DeviceMenuAction>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppColors.textSecondary,
                        size: 19,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onSelected: (action) {
                        switch (action) {
                          case DeviceMenuAction.viewDetails:
                            onViewDetails();
                            break;
                          case DeviceMenuAction.renameAlias:
                            onRenameAlias();
                            break;
                          case DeviceMenuAction.limitBandwidth:
                            onLimitBandwidth();
                            break;
                          case DeviceMenuAction.assignStaticIp:
                            onAssignStaticIp();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: DeviceMenuAction.viewDetails,
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: 18, color: AppColors.textPrimary),
                              SizedBox(width: 10),
                              Text('Ver Detalles', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: DeviceMenuAction.renameAlias,
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
                              SizedBox(width: 10),
                              Text('Renombrar Alias', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: DeviceMenuAction.limitBandwidth,
                          child: Row(
                            children: [
                              Icon(Icons.speed_outlined, size: 18, color: AppColors.textPrimary),
                              SizedBox(width: 10),
                              Text('Limitar Ancho de Banda', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: DeviceMenuAction.assignStaticIp,
                          child: Row(
                            children: [
                              const Icon(Icons.pin_outlined, size: 18, color: AppColors.textPrimary),
                              const SizedBox(width: 10),
                              Text(
                                device.isStaticIp ? 'Desactivar IP Estática' : 'Asignar IP Estática',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Bottom Row: MAC Address Chip & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // MAC Address Code Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isBlocked
                            ? Colors.white
                            : AppColors.scaffoldBackground,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.fingerprint_outlined,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            device.mac,
                            style: AppTypography.monoCode.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isBlocked)
                      const StatusBadge(
                        label: 'Bloqueado',
                        type: StatusBadgeType.blocked,
                      )
                    else if (device.bandwidthLimitMbps != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.statusWarningBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Límite: ${device.bandwidthLimitMbps!.toStringAsFixed(0)} Mbps',
                          style: AppTypography.chipText.copyWith(
                            color: AppColors.statusWarning,
                            fontSize: 10,
                          ),
                        ),
                      )
                    else
                      Text(
                        '${device.signalStrengthPercent}% Señal',
                        style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          color: AppColors.statusSuccess,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
