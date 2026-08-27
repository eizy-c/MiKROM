import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../dashboard/models/device_model.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../providers/access_control_provider.dart';
import '../widgets/blocked_device_tile.dart';
import '../widgets/manual_mac_dialog.dart';

/// Access Control and MAC Filtering View.
class AccessControlView extends ConsumerStatefulWidget {
  const AccessControlView({super.key});

  @override
  ConsumerState<AccessControlView> createState() => _AccessControlViewState();
}

class _AccessControlViewState extends ConsumerState<AccessControlView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blockedList = ref.watch(blockedDevicesProvider);
    final allowedList = ref.watch(allowedDevicesProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Control de Acceso',
              style: AppTypography.sectionHeader.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Filtro de Direcciones MAC & Lista Negra',
              style: AppTypography.caption.copyWith(fontSize: 10),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_moderator_outlined),
            tooltip: 'Añadir MAC Manual',
            onPressed: () => _showAddMacDialog(context, ref),
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTypography.bodyBold.copyWith(fontSize: 13),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.block_outlined, size: 16),
                  const SizedBox(width: 8),
                  Text('Bloqueados (${blockedList.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 16),
                  const SizedBox(width: 8),
                  Text('Permitidos (${allowedList.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Blocked Devices
          _buildBlockedTab(context, ref, blockedList),

          // Tab 2: Allowed Devices
          _buildAllowedTab(context, ref, allowedList),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          'Bloquear Nueva MAC',
          style: AppTypography.chipText.copyWith(color: Colors.white, fontSize: 13),
        ),
        onPressed: () => _showAddMacDialog(context, ref),
      ),
    );
  }

  Widget _buildBlockedTab(BuildContext context, WidgetRef ref, List<DeviceModel> blockedList) {
    if (blockedList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.statusSuccessBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.statusSuccess.withValues(alpha: 0.3)),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.statusSuccess,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No hay dispositivos bloqueados',
                style: AppTypography.sectionHeader.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                'Todos los clientes autorizados tienen acceso a la red local e Internet.',
                style: AppTypography.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.statusDangerBg.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.statusDanger.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 18, color: AppColors.statusDanger),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Los clientes en esta lista tienen prohibido el tráfico DHCP y el enrutamiento.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.statusDanger,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...blockedList.map(
          (device) => BlockedDeviceTile(
            device: device,
            onUnblock: () async {
              final ok = await ref
                  .read(devicesProvider.notifier)
                  .toggleDeviceBlock(device.mac, false);
              if (context.mounted) {
                if (ok) {
                  CustomSnackBar.showSuccess(
                    context,
                    'Acceso desbloqueado para ${device.displayName} (${device.mac})',
                  );
                } else {
                  CustomSnackBar.showError(
                    context,
                    'Error al desbloquear MAC en el router.',
                  );
                }
              }
            },
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildAllowedTab(BuildContext context, WidgetRef ref, List<DeviceModel> allowedList) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: allowedList.length,
      itemBuilder: (context, index) {
        final device = allowedList[index];
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.statusSuccessBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(device.iconData, color: AppColors.statusSuccess, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.displayName,
                      style: AppTypography.bodyBold.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${device.ip} • ${device.mac}',
                      style: AppTypography.monoCodeSmall,
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.statusDanger,
                  side: const BorderSide(color: AppColors.statusDanger),
                  minimumSize: const Size(80, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  await ref
                      .read(devicesProvider.notifier)
                      .toggleDeviceBlock(device.mac, true);
                  if (context.mounted) {
                    CustomSnackBar.showWarning(
                      context,
                      '${device.displayName} ha sido bloqueado.',
                    );
                  }
                },
                child: Text(
                  'Bloquear',
                  style: AppTypography.chipText.copyWith(
                    color: AppColors.statusDanger,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddMacDialog(BuildContext context, WidgetRef ref) {
    ManualMacDialog.show(
      context,
      onAdd: (mac, alias, blockImmediately) async {
        final newDevice = DeviceModel(
          ip: '0.0.0.0',
          mac: mac,
          hostname: alias ?? 'Host Registrado Manual',
          customAlias: alias,
          isBlocked: blockImmediately,
        );

        ref.read(devicesProvider.notifier).addManualDevice(newDevice);

        if (blockImmediately) {
          await ref.read(devicesProvider.notifier).toggleDeviceBlock(mac, true);
          if (context.mounted) {
            CustomSnackBar.showWarning(context, 'Dirección MAC $mac bloqueada.');
          }
        } else {
          if (context.mounted) {
            CustomSnackBar.showSuccess(context, 'Dirección MAC $mac agregada a la lista blanca.');
          }
        }
      },
    );
  }
}
