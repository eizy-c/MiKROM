import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/ip_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../models/adapter_config_model.dart';
import '../providers/network_settings_provider.dart';

/// Network Adapter and Subnet Mask configuration view.
class NetworkSettingsView extends ConsumerStatefulWidget {
  const NetworkSettingsView({super.key});

  @override
  ConsumerState<NetworkSettingsView> createState() => _NetworkSettingsViewState();
}

class _NetworkSettingsViewState extends ConsumerState<NetworkSettingsView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _interfaceController;
  late TextEditingController _ipController;
  late TextEditingController _prefixController;
  late TextEditingController _maskController;
  late TextEditingController _gatewayController;
  late TextEditingController _primaryDnsController;
  late TextEditingController _secondaryDnsController;

  bool _dhcpEnabled = true;

  @override
  void initState() {
    super.initState();
    final config = ref.read(networkSettingsProvider).config;
    _interfaceController = TextEditingController(text: config.interfaceName);
    _ipController = TextEditingController(text: config.ip);
    _prefixController = TextEditingController(text: config.prefix.toString());
    _maskController = TextEditingController(text: config.subnetMask);
    _gatewayController = TextEditingController(text: config.gateway);
    _primaryDnsController = TextEditingController(text: config.primaryDns);
    _secondaryDnsController = TextEditingController(text: config.secondaryDns);
    _dhcpEnabled = config.dhcpEnabled;
  }

  @override
  void dispose() {
    _interfaceController.dispose();
    _ipController.dispose();
    _prefixController.dispose();
    _maskController.dispose();
    _gatewayController.dispose();
    _primaryDnsController.dispose();
    _secondaryDnsController.dispose();
    super.dispose();
  }

  void _onPrefixChanged(String val) {
    final prefix = int.tryParse(val.trim());
    if (prefix != null && prefix >= 0 && prefix <= 32) {
      final mask = IpUtils.cidrToSubnetMask(prefix);
      if (_maskController.text != mask) {
        _maskController.text = mask;
      }
      setState(() {});
    }
  }

  void _onMaskChanged(String val) {
    if (Validators.validateIPv4(val, fieldName: 'Máscara') == null) {
      final prefix = IpUtils.subnetMaskToCidr(val);
      if (_prefixController.text != prefix.toString()) {
        _prefixController.text = prefix.toString();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final networkState = ref.watch(networkSettingsProvider);
    final currentPrefix = int.tryParse(_prefixController.text.trim()) ?? 24;
    final usableHosts = IpUtils.hostCountForPrefix(currentPrefix);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración LAN / IP',
              style: AppTypography.sectionHeader.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Parámetros de Adaptador & Subred',
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
              // 1. Adapter Identification
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
                            Icons.settings_ethernet_outlined,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Adaptador de Red Local',
                          style: AppTypography.bodyBold.copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Interface selector
                    TextFormField(
                      controller: _interfaceController,
                      style: AppTypography.monoCode.copyWith(fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Interfaz de Red (Adaptador)',
                        hintText: 'eth0 / wlan0 / br0',
                        prefixIcon: Icon(Icons.cable_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Local Router IP
                    TextFormField(
                      controller: _ipController,
                      validator: (val) => Validators.validateIPv4(val, fieldName: 'IP Local'),
                      style: AppTypography.monoCodeBold.copyWith(fontSize: 14),
                      decoration: const InputDecoration(
                        labelText: 'Dirección IP Local del Router *',
                        hintText: '192.168.1.1',
                        prefixIcon: Icon(Icons.router_outlined, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Subnet Mask & CIDR Calculator
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
                            Icons.tune_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Máscara de Subred & Rango CIDR',
                          style: AppTypography.bodyBold.copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        // CIDR Prefix Input
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            controller: _prefixController,
                            validator: Validators.validatePrefix,
                            keyboardType: TextInputType.number,
                            style: AppTypography.monoCodeBold.copyWith(fontSize: 14),
                            onChanged: _onPrefixChanged,
                            decoration: const InputDecoration(
                              labelText: 'CIDR *',
                              prefixText: '/',
                              hintText: '24',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Decimal Mask Input
                        Expanded(
                          child: TextFormField(
                            controller: _maskController,
                            validator: (val) => Validators.validateIPv4(val, fieldName: 'Máscara Decimal'),
                            style: AppTypography.monoCode.copyWith(fontSize: 13),
                            onChanged: _onMaskChanged,
                            decoration: const InputDecoration(
                              labelText: 'Máscara Decimal *',
                              hintText: '255.255.255.0',
                              prefixIcon: Icon(Icons.grid_4x4_outlined, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Subnet info badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: AppColors.secondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Capacidad calculada: $usableHosts direcciones IP asignables (/$currentPrefix).',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Gateway & DNS Servers
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
                            color: AppColors.statusSuccessBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.public_outlined,
                            color: AppColors.statusSuccess,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Puerta de Enlace & DNS',
                          style: AppTypography.bodyBold.copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Default Gateway
                    TextFormField(
                      controller: _gatewayController,
                      validator: (val) => Validators.validateIPv4(val, fieldName: 'Puerta de Enlace'),
                      style: AppTypography.monoCode.copyWith(fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Puerta de Enlace Predeterminada (Gateway) *',
                        hintText: '192.168.1.254',
                        prefixIcon: Icon(Icons.login_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // DNS Primario
                    TextFormField(
                      controller: _primaryDnsController,
                      validator: (val) => Validators.validateIPv4(val, fieldName: 'DNS Primario'),
                      style: AppTypography.monoCode.copyWith(fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Servidor DNS Primario *',
                        hintText: '1.1.1.1 (Cloudflare)',
                        prefixIcon: Icon(Icons.dns_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // DNS Secundario
                    TextFormField(
                      controller: _secondaryDnsController,
                      validator: (val) => Validators.validateIPv4(val, fieldName: 'DNS Secundario'),
                      style: AppTypography.monoCode.copyWith(fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Servidor DNS Secundario (Opcional)',
                        hintText: '8.8.8.8 (Google)',
                        prefixIcon: Icon(Icons.dns_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // DHCP Switch
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
                              const Icon(Icons.sync_outlined, size: 18, color: AppColors.textSecondary),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Servidor DHCP Local',
                                    style: AppTypography.bodyBold.copyWith(fontSize: 13),
                                  ),
                                  Text(
                                    'Asignación automática de IPs a clientes',
                                    style: AppTypography.caption.copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Switch(
                            value: _dhcpEnabled,
                            activeThumbColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() => _dhcpEnabled = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Save Button
              ElevatedButton.icon(
                icon: networkState.isSaving
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
                  networkState.isSaving
                      ? 'Actualizando máscara de red...'
                      : 'Guardar Configuración de Red',
                ),
                onPressed: networkState.isSaving
                    ? null
                    : () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          final config = AdapterConfigModel(
                            interfaceName: _interfaceController.text.trim(),
                            ip: _ipController.text.trim(),
                            prefix: int.parse(_prefixController.text.trim()),
                            gateway: _gatewayController.text.trim(),
                            primaryDns: _primaryDnsController.text.trim(),
                            secondaryDns: _secondaryDnsController.text.trim(),
                            dhcpEnabled: _dhcpEnabled,
                          );

                          final ok = await ref
                              .read(networkSettingsProvider.notifier)
                              .saveConfig(config);

                          if (context.mounted) {
                            if (ok) {
                              CustomSnackBar.showSuccess(
                                context,
                                'Máscara y parámetros LAN actualizados exitosamente en /api/network/set-mask',
                              );
                            } else {
                              CustomSnackBar.showError(
                                context,
                                'Error al enviar parámetros al router.',
                              );
                            }
                          }
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
