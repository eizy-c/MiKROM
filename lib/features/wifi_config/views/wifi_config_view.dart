import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../models/wifi_config_model.dart';
import '../providers/wifi_config_provider.dart';
import '../widgets/restart_confirmation_dialog.dart';

/// Wi-Fi Configuration Settings View.
class WifiConfigView extends ConsumerStatefulWidget {
  const WifiConfigView({super.key});

  @override
  ConsumerState<WifiConfigView> createState() => _WifiConfigViewState();
}

class _WifiConfigViewState extends ConsumerState<WifiConfigView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ssidController;
  late TextEditingController _passwordController;

  bool _obscurePassword = true;
  String _selectedSecurity = 'WPA2/WPA3-Mixed';
  String _selectedBand = '5 GHz';
  String _selectedChannel = 'Auto';
  bool _isHiddenSsid = false;
  String _selectedTxPower = '100% (Alto)';

  final List<String> _securityOptions = [
    'WPA2/WPA3-Mixed',
    'WPA3-SAE',
    'WPA2-PSK (AES)',
    'Abierta (Sin Seguridad)',
  ];

  final List<String> _bandOptions = [
    '5 GHz',
    '2.4 GHz',
    'Dual-Band Simultáneo',
  ];

  final List<String> _channels24 = ['Auto', '1', '6', '11'];
  final List<String> _channels5 = ['Auto', '36', '40', '44', '48', '149', '153', '157', '161'];

  @override
  void initState() {
    super.initState();
    final current = ref.read(wifiConfigProvider).config;
    _ssidController = TextEditingController(text: current.ssid);
    _passwordController = TextEditingController(text: current.password);
    _selectedSecurity = current.security;
    _selectedBand = current.band;
    _selectedChannel = current.channel;
    _isHiddenSsid = current.isHidden;
    _selectedTxPower = current.txPower;
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  List<String> get _currentChannels {
    if (_selectedBand == '2.4 GHz') return _channels24;
    return _channels5;
  }

  @override
  Widget build(BuildContext context) {
    final wifiState = ref.watch(wifiConfigProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ajustes Inalámbricos',
              style: AppTypography.sectionHeader.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Configuración de Red Wi-Fi & Seguridad',
              style: AppTypography.caption.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Basic Radio Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.wifi_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Transmisión de Red (SSID)',
                          style: AppTypography.bodyBold.copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // SSID Field
                    TextFormField(
                      controller: _ssidController,
                      validator: Validators.validateSsid,
                      style: AppTypography.bodyBold.copyWith(fontSize: 14),
                      decoration: const InputDecoration(
                        labelText: 'Nombre de Red (SSID) *',
                        hintText: 'Ej: MiKROM-Oficina-5G',
                        prefixIcon: Icon(Icons.wifi_tethering_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Security Selector
                    DropdownButtonFormField<String>(
                      initialValue: _securityOptions.contains(_selectedSecurity)
                          ? _selectedSecurity
                          : _securityOptions.first,
                      decoration: const InputDecoration(
                        labelText: 'Modo de Seguridad',
                        prefixIcon: Icon(Icons.lock_outline, size: 20),
                      ),
                      items: _securityOptions.map((sec) {
                        return DropdownMenuItem(
                          value: sec,
                          child: Text(sec, style: AppTypography.bodyRegular),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedSecurity = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Password Field
                    if (_selectedSecurity != 'Abierta (Sin Seguridad)')
                      TextFormField(
                        controller: _passwordController,
                        validator: Validators.validateWifiPassword,
                        obscureText: _obscurePassword,
                        style: AppTypography.monoCode.copyWith(fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Contraseña de Red (WPA Key) *',
                          hintText: 'Mínimo 8 caracteres',
                          prefixIcon: const Icon(Icons.key_outlined, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 14),

                    // Hide SSID Switch
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.visibility_off_outlined,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ocultar SSID (Red Invisible)',
                                    style: AppTypography.bodyBold.copyWith(fontSize: 13),
                                  ),
                                  Text(
                                    'No difundir nombre en escaneos públicos',
                                    style: AppTypography.caption.copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Switch(
                            value: _isHiddenSsid,
                            activeThumbColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() => _isHiddenSsid = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Radio Frequency & Hardware Settings
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.settings_input_antenna_outlined,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Banda & Canales de Transmisión',
                          style: AppTypography.bodyBold.copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Band Selector
                    DropdownButtonFormField<String>(
                      initialValue: _selectedBand,
                      decoration: const InputDecoration(
                        labelText: 'Banda de Frecuencia',
                        prefixIcon: Icon(Icons.tune_outlined, size: 20),
                      ),
                      items: _bandOptions.map((band) {
                        return DropdownMenuItem(
                          value: band,
                          child: Text(band, style: AppTypography.bodyRegular),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedBand = val;
                            _selectedChannel = 'Auto';
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Channel Selector
                    DropdownButtonFormField<String>(
                      initialValue: _currentChannels.contains(_selectedChannel)
                          ? _selectedChannel
                          : _currentChannels.first,
                      decoration: const InputDecoration(
                        labelText: 'Canal de Radio',
                        prefixIcon: Icon(Icons.wifi_channel_outlined, size: 20),
                      ),
                      items: _currentChannels.map((ch) {
                        return DropdownMenuItem(
                          value: ch,
                          child: Text(
                            ch == 'Auto' ? 'Automático (Recomendado)' : 'Canal $ch',
                            style: AppTypography.bodyRegular,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedChannel = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Power TX
                    DropdownButtonFormField<String>(
                      initialValue: _selectedTxPower,
                      decoration: const InputDecoration(
                        labelText: 'Potencia de Transmisión (TX)',
                        prefixIcon: Icon(Icons.bolt_outlined, size: 20),
                      ),
                      items: const [
                        DropdownMenuItem(value: '100% (Alto)', child: Text('100% (Alto - Máx Cobertura)')),
                        DropdownMenuItem(value: '75% (Medio)', child: Text('75% (Medio - Eficiente)')),
                        DropdownMenuItem(value: '50% (Bajo)', child: Text('50% (Bajo - Ahorro)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedTxPower = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Save Button
              ElevatedButton.icon(
                icon: wifiState.isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 20),
                label: Text(
                  wifiState.isSaving
                      ? 'Aplicando configuración...'
                      : 'Guardar y Aplicar Ajustes',
                ),
                onPressed: wifiState.isSaving
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final newConfig = WifiConfigModel(
                            ssid: _ssidController.text.trim(),
                            password: _passwordController.text,
                            security: _selectedSecurity,
                            band: _selectedBand,
                            channel: _selectedChannel,
                            isHidden: _isHiddenSsid,
                            txPower: _selectedTxPower,
                          );

                          RestartConfirmationDialog.show(
                            context,
                            newSsid: newConfig.ssid,
                            onConfirm: () async {
                              final ok = await ref
                                  .read(wifiConfigProvider.notifier)
                                  .saveConfig(newConfig);
                              if (context.mounted) {
                                if (ok) {
                                  CustomSnackBar.showSuccess(
                                    context,
                                    'Ajustes de Wi-Fi aplicados con éxito. Interfaz reiniciada.',
                                  );
                                } else {
                                  CustomSnackBar.showError(
                                    context,
                                    'No se pudo aplicar la configuración en el router.',
                                  );
                                }
                              }
                            },
                          );
                        }
                      },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
