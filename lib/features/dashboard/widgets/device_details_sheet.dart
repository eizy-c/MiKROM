import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/device_model.dart';

/// Modal bottom sheet with complete host inspection and parameters edit.
class DeviceDetailsSheet extends StatefulWidget {
  final DeviceModel device;
  final ValueChanged<String> onRename;
  final ValueChanged<bool> onToggleStaticIp;
  final ValueChanged<double?> onSetBandwidthLimit;
  final ValueChanged<bool> onToggleBlock;

  const DeviceDetailsSheet({
    super.key,
    required this.device,
    required this.onRename,
    required this.onToggleStaticIp,
    required this.onSetBandwidthLimit,
    required this.onToggleBlock,
  });

  static Future<void> show(
    BuildContext context, {
    required DeviceModel device,
    required ValueChanged<String> onRename,
    required ValueChanged<bool> onToggleStaticIp,
    required ValueChanged<double?> onSetBandwidthLimit,
    required ValueChanged<bool> onToggleBlock,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DeviceDetailsSheet(
        device: device,
        onRename: onRename,
        onToggleStaticIp: onToggleStaticIp,
        onSetBandwidthLimit: onSetBandwidthLimit,
        onToggleBlock: onToggleBlock,
      ),
    );
  }

  @override
  State<DeviceDetailsSheet> createState() => _DeviceDetailsSheetState();
}

class _DeviceDetailsSheetState extends State<DeviceDetailsSheet> {
  late TextEditingController _aliasController;
  late TextEditingController _limitController;
  late bool _isStaticIp;
  late bool _isBlocked;

  @override
  void initState() {
    super.initState();
    _aliasController = TextEditingController(text: widget.device.customAlias ?? '');
    _limitController = TextEditingController(
      text: widget.device.bandwidthLimitMbps != null
          ? widget.device.bandwidthLimitMbps!.toStringAsFixed(0)
          : '',
    );
    _isStaticIp = widget.device.isStaticIp;
    _isBlocked = widget.device.isBlocked;
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = widget.device;
    final dateStr = device.connectedAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(device.connectedAt!)
        : 'Desconocido';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header Row
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Icon(device.iconData, color: AppColors.textPrimary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.displayName,
                        style: AppTypography.sectionHeader.copyWith(fontSize: 17),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Hostname original: ${device.hostname}',
                        style: AppTypography.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: _isBlocked ? 'Bloqueado' : 'Conectado',
                  type: _isBlocked ? StatusBadgeType.blocked : StatusBadgeType.online,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // Technical Grid
            Text(
              'Parámetros de Red',
              style: AppTypography.bodyBold.copyWith(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Dirección IP', device.ip, isMono: true),
                  const Divider(height: 16),
                  _buildDetailRow('Dirección MAC', device.mac, isMono: true),
                  const Divider(height: 16),
                  _buildDetailRow('Banda Wi-Fi', '${device.band} (Señal ${device.signalStrengthPercent}%)'),
                  const Divider(height: 16),
                  _buildDetailRow('Consumo Actual', 'DL: ${Formatters.formatSpeed(device.downloadSpeedMbps)} | UL: ${Formatters.formatSpeed(device.uploadSpeedMbps)}'),
                  const Divider(height: 16),
                  _buildDetailRow('Conectado Desde', dateStr),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Edit Settings Section
            Text(
              'Acciones y Configuración',
              style: AppTypography.bodyBold.copyWith(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),

            // Alias input
            TextField(
              controller: _aliasController,
              decoration: const InputDecoration(
                labelText: 'Alias personalizado (Nombre amigable)',
                hintText: 'Ej: Laptop Oficina Juan',
                prefixIcon: Icon(Icons.badge_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 12),

            // Bandwidth Limit
            TextField(
              controller: _limitController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Límite de Ancho de Banda (Mbps)',
                hintText: 'Dejar vacío para sin límite',
                prefixIcon: Icon(Icons.speed_outlined, size: 20),
                suffixText: 'Mbps',
              ),
            ),
            const SizedBox(height: 12),

            // Static IP Switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pin_outlined, size: 20, color: AppColors.textPrimary),
                      const SizedBox(width: 10),
                      Text(
                        'Asignar IP Estática Fija',
                        style: AppTypography.bodyRegular.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: _isStaticIp,
                    activeThumbColor: AppColors.secondary,
                    onChanged: (val) {
                      setState(() => _isStaticIp = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Block access button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: _isBlocked ? AppColors.statusSuccess : AppColors.statusDanger,
                side: BorderSide(
                  color: _isBlocked ? AppColors.statusSuccess : AppColors.statusDanger,
                ),
              ),
              icon: Icon(_isBlocked ? Icons.check_circle_outline : Icons.block_outlined, size: 18),
              label: Text(_isBlocked ? 'Permitir Acceso a la Red' : 'Bloquear Acceso a la Red'),
              onPressed: () {
                final newBlocked = !_isBlocked;
                setState(() => _isBlocked = newBlocked);
                widget.onToggleBlock(newBlocked);
              },
            ),
            const SizedBox(height: 16),

            // Save modifications button
            ElevatedButton(
              onPressed: () {
                widget.onRename(_aliasController.text);
                widget.onToggleStaticIp(_isStaticIp);
                final limit = double.tryParse(_limitController.text.trim());
                widget.onSetBandwidthLimit(limit);
                Navigator.of(context).pop();
              },
              child: const Text('Guardar Modificaciones'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isMono = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.caption),
        Flexible(
          child: Text(
            value,
            style: isMono
                ? AppTypography.monoCodeBold.copyWith(fontSize: 12)
                : AppTypography.bodyBold.copyWith(fontSize: 12),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
