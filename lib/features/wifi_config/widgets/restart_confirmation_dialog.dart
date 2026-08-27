import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

/// Confirmation dialog for Wi-Fi settings application and interface reboot.
class RestartConfirmationDialog extends StatelessWidget {
  final String newSsid;
  final VoidCallback onConfirm;

  const RestartConfirmationDialog({
    super.key,
    required this.newSsid,
    required this.onConfirm,
  });

  static Future<bool?> show(BuildContext context, {required String newSsid, required VoidCallback onConfirm}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => RestartConfirmationDialog(
        newSsid: newSsid,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.statusWarningBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.statusWarning,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Confirmar Reinicio Wi-Fi',
            style: AppTypography.sectionHeader.copyWith(fontSize: 16),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Al aplicar los nuevos cambios en la red "$newSsid", el módulo de radio se reiniciará inmediatamente.',
            style: AppTypography.bodyRegular.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.statusWarningBg.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.statusWarning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.statusWarning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Todos los clientes conectados perderán la conexión momentáneamente durante 10-15 segundos.',
                    style: AppTypography.caption.copyWith(
                      color: const Color(0xFF92400E), // Warm amber dark
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '¿Deseas proceder con la actualización?',
            style: AppTypography.bodyBold.copyWith(fontSize: 13),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancelar',
            style: AppTypography.bodyRegular.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(110, 42),
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm();
          },
          child: const Text('Aplicar Cambios'),
        ),
      ],
    );
  }
}
