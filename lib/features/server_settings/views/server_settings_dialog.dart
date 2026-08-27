import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../providers/server_settings_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';

/// Dialog to configure backend router daemon host & demo mode.
class ServerSettingsDialog extends ConsumerStatefulWidget {
  const ServerSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const ServerSettingsDialog(),
    );
  }

  @override
  ConsumerState<ServerSettingsDialog> createState() => _ServerSettingsDialogState();
}

class _ServerSettingsDialogState extends ConsumerState<ServerSettingsDialog> {
  late TextEditingController _urlController;
  late bool _isDemoMode;

  @override
  void initState() {
    super.initState();
    final serverState = ref.read(serverSettingsProvider);
    _urlController = TextEditingController(text: serverState.baseUrl);
    _isDemoMode = serverState.isDemoMode;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.dns_outlined,
              color: AppColors.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Host del Router / Servidor',
            style: AppTypography.sectionHeader.copyWith(fontSize: 16),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configura la dirección IP y puerto del daemon REST en tu router local:',
              style: AppTypography.bodyRegular.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL Base del Endpoint',
                hintText: 'http://192.168.1.1:8080',
                prefixIcon: Icon(Icons.link_outlined, size: 20),
              ),
              style: AppTypography.monoCode.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Modo Demostración / Simulación',
                          style: AppTypography.bodyBold.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Usa datos locales si el router físico está apagado.',
                          style: AppTypography.caption.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isDemoMode,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() => _isDemoMode = val);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
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
            minimumSize: const Size(120, 42),
          ),
          onPressed: () async {
            final newUrl = _urlController.text.trim();
            if (newUrl.isEmpty) return;

            final messenger = ScaffoldMessenger.of(context);
            final navigator = Navigator.of(context);

            final settingsNotifier = ref.read(serverSettingsProvider.notifier);
            await settingsNotifier.updateBaseUrl(newUrl);
            await settingsNotifier.toggleDemoMode(_isDemoMode);

            // Trigger devices re-fetch
            ref.read(devicesProvider.notifier).fetchDevices();

            navigator.pop();
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.darkSlate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: AppColors.statusSuccess.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: AppColors.statusSuccess, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Configuración del servidor guardada exitosamente.',
                        style: AppTypography.bodyRegular.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: const Text('Guardar y Reconectar'),
        ),
      ],
    );
  }
}
