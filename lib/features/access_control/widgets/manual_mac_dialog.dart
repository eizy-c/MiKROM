import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';

/// Modal dialog for manually registering and blocking a MAC address.
class ManualMacDialog extends StatefulWidget {
  final Function(String mac, String? alias, bool blockImmediately) onAdd;

  const ManualMacDialog({
    super.key,
    required this.onAdd,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(String mac, String? alias, bool blockImmediately) onAdd,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ManualMacDialog(onAdd: onAdd),
    );
  }

  @override
  State<ManualMacDialog> createState() => _ManualMacDialogState();
}

class _ManualMacDialogState extends State<ManualMacDialog> {
  final _formKey = GlobalKey<FormState>();
  final _macController = TextEditingController();
  final _aliasController = TextEditingController();
  bool _blockImmediately = true;

  @override
  void dispose() {
    _macController.dispose();
    _aliasController.dispose();
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.statusDangerBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.security_outlined,
              color: AppColors.statusDanger,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Añadir Regla de MAC',
            style: AppTypography.sectionHeader.copyWith(fontSize: 16),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ingresa la dirección física MAC del adaptador a registrar:',
                style: AppTypography.bodyRegular.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 14),

              // MAC Address Field
              TextFormField(
                controller: _macController,
                validator: Validators.validateMac,
                textCapitalization: TextCapitalization.characters,
                style: AppTypography.monoCode.copyWith(fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'Dirección MAC *',
                  hintText: 'AA:BB:CC:DD:EE:FF',
                  prefixIcon: Icon(Icons.fingerprint_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 12),

              // Optional Alias
              TextFormField(
                controller: _aliasController,
                style: AppTypography.bodyRegular.copyWith(fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'Alias / Descripción (Opcional)',
                  hintText: 'Ej: Smartphone Intruso',
                  prefixIcon: Icon(Icons.label_outline, size: 20),
                ),
              ),
              const SizedBox(height: 14),

              // Action selector (Block vs Whitelist)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        Icon(
                          _blockImmediately ? Icons.block_outlined : Icons.check_circle_outline,
                          size: 18,
                          color: _blockImmediately ? AppColors.statusDanger : AppColors.statusSuccess,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _blockImmediately ? 'Bloquear inmediatamente' : 'Registrar como permitido',
                          style: AppTypography.bodyBold.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                    Switch(
                      value: _blockImmediately,
                      activeThumbColor: AppColors.statusDanger,
                      onChanged: (val) {
                        setState(() => _blockImmediately = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
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
            backgroundColor: _blockImmediately ? AppColors.statusDanger : AppColors.primary,
            minimumSize: const Size(110, 42),
          ),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final normMac = Formatters.normalizeMac(_macController.text);
              final alias = _aliasController.text.trim().isEmpty ? null : _aliasController.text.trim();
              widget.onAdd(normMac, alias, _blockImmediately);
              Navigator.of(context).pop();
            }
          },
          child: Text(_blockImmediately ? 'Bloquear MAC' : 'Guardar MAC'),
        ),
      ],
    );
  }
}
