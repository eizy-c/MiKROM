import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../server_settings/views/server_settings_dialog.dart';
import '../models/device_model.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/device_card.dart';
import '../widgets/device_details_sheet.dart';
import '../widgets/header_status_card.dart';
import '../widgets/skeleton_device_list.dart';
import '../widgets/traffic_summary_card.dart';

/// Main Dashboard View (Home).
class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesState = ref.watch(devicesProvider);
    final statsAsync = ref.watch(networkStatsProvider);
    final filteredDevices = ref.watch(filteredDevicesProvider);
    final currentFilter = ref.watch(deviceFilterTypeProvider);
    final searchQuery = ref.watch(deviceSearchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.hub_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MiKROM',
                  style: AppTypography.sectionHeader.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Panel de Control de Red',
                  style: AppTypography.caption.copyWith(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Refrescar Lista',
            onPressed: () {
              ref.read(devicesProvider.notifier).fetchDevices();
              CustomSnackBar.showInfo(context, 'Actualizando clientes de la red...');
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await ref.read(devicesProvider.notifier).fetchDevices(isManualScan: true);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            // 1. Header Status Card
            statsAsync.when(
              data: (stats) => HeaderStatusCard(
                ssid: stats.ssid,
                isOnline: stats.isOnline,
                isScanning: devicesState.isScanning,
                onScanPressed: () {
                  ref.read(devicesProvider.notifier).fetchDevices(isManualScan: true);
                  CustomSnackBar.showInfo(context, 'Escaneando dispositivos en la subred...');
                },
                onServerConfigPressed: () => ServerSettingsDialog.show(context),
              ),
              loading: () => HeaderStatusCard(
                ssid: 'Cargando red...',
                isOnline: true,
                isScanning: true,
                onScanPressed: () {},
                onServerConfigPressed: () => ServerSettingsDialog.show(context),
              ),
              error: (err, stack) => HeaderStatusCard(
                ssid: 'MiKROM-Router',
                isOnline: false,
                isScanning: false,
                onScanPressed: () {
                  ref.read(devicesProvider.notifier).fetchDevices();
                },
                onServerConfigPressed: () => ServerSettingsDialog.show(context),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Traffic Summary Card
            statsAsync.maybeWhen(
              data: (stats) => TrafficSummaryCard(stats: stats),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 18),

            // 3. Search & Filter Bar
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      onChanged: (val) =>
                          ref.read(deviceSearchQueryProvider.notifier).state = val,
                      decoration: InputDecoration(
                        hintText: 'Buscar por IP, MAC o Hostname...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => ref
                                    .read(deviceSearchQueryProvider.notifier)
                                    .state = '',
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'Todos (${devicesState.devices.length})',
                    isSelected: currentFilter == null,
                    onSelected: () =>
                        ref.read(deviceFilterTypeProvider.notifier).state = null,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Laptops',
                    isSelected: currentFilter == DeviceType.laptop,
                    onSelected: () => ref
                        .read(deviceFilterTypeProvider.notifier)
                        .state = DeviceType.laptop,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Smartphones',
                    isSelected: currentFilter == DeviceType.smartphone,
                    onSelected: () => ref
                        .read(deviceFilterTypeProvider.notifier)
                        .state = DeviceType.smartphone,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Consolas',
                    isSelected: currentFilter == DeviceType.console,
                    onSelected: () => ref
                        .read(deviceFilterTypeProvider.notifier)
                        .state = DeviceType.console,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Smart TV',
                    isSelected: currentFilter == DeviceType.smartTv,
                    onSelected: () => ref
                        .read(deviceFilterTypeProvider.notifier)
                        .state = DeviceType.smartTv,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'IoT',
                    isSelected: currentFilter == DeviceType.iot,
                    onSelected: () => ref
                        .read(deviceFilterTypeProvider.notifier)
                        .state = DeviceType.iot,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Clientes Conectados',
                  style: AppTypography.sectionHeader,
                ),
                Text(
                  '${filteredDevices.length} hosts',
                  style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 4. Devices List / Skeletons
            if (devicesState.isLoading || devicesState.isScanning)
              const SkeletonDeviceList(itemCount: 4)
            else if (filteredDevices.isEmpty)
              _buildEmptyState(context, searchQuery.isNotEmpty)
            else
              ...filteredDevices.map(
                (device) => DeviceCard(
                  device: device,
                  onBlockToggle: (shouldBlock) async {
                    final ok = await ref
                        .read(devicesProvider.notifier)
                        .toggleDeviceBlock(device.mac, shouldBlock);
                    if (ok) {
                      if (context.mounted) {
                        if (shouldBlock) {
                          CustomSnackBar.showWarning(
                            context,
                            'Acceso bloqueado para ${device.displayName}',
                          );
                        } else {
                          CustomSnackBar.showSuccess(
                            context,
                            'Acceso restaurado para ${device.displayName}',
                          );
                        }
                      }
                    } else {
                      if (context.mounted) {
                        CustomSnackBar.showError(
                          context,
                          'Error al actualizar regla de acceso en el router.',
                        );
                      }
                    }
                  },
                  onViewDetails: () => _openDeviceDetails(context, ref, device),
                  onRenameAlias: () => _showRenameDialog(context, ref, device),
                  onLimitBandwidth: () => _showLimitDialog(context, ref, device),
                  onAssignStaticIp: () {
                    final newStatic = !device.isStaticIp;
                    ref
                        .read(devicesProvider.notifier)
                        .toggleStaticIp(device.mac, newStatic);
                    CustomSnackBar.showSuccess(
                      context,
                      newStatic
                          ? 'IP Estática asignada a ${device.displayName}'
                          : 'Modo DHCP dinámico restaurado',
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkSlate : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.darkSlate : AppColors.cardBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.chipText.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSearch) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Icon(
              Icons.search_off_outlined,
              color: AppColors.textMuted,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isSearch ? 'Sin coincidencias' : 'No hay dispositivos conectados',
            style: AppTypography.sectionHeader.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            isSearch
                ? 'Prueba con otra IP, MAC o nombre de host.'
                : 'Presiona "Escanear Red" para descubrir nuevos clientes.',
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _openDeviceDetails(BuildContext context, WidgetRef ref, DeviceModel device) {
    DeviceDetailsSheet.show(
      context,
      device: device,
      onRename: (alias) =>
          ref.read(devicesProvider.notifier).updateDeviceAlias(device.mac, alias),
      onToggleStaticIp: (val) =>
          ref.read(devicesProvider.notifier).toggleStaticIp(device.mac, val),
      onSetBandwidthLimit: (limit) =>
          ref.read(devicesProvider.notifier).setBandwidthLimit(device.mac, limit),
      onToggleBlock: (block) =>
          ref.read(devicesProvider.notifier).toggleDeviceBlock(device.mac, block),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, DeviceModel device) {
    final controller = TextEditingController(text: device.customAlias ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        backgroundColor: Colors.white,
        title: Text('Renombrar Alias', style: AppTypography.sectionHeader),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Alias personalizado',
            hintText: 'Ej: Smartphone Trabajo',
            prefixIcon: Icon(Icons.edit_outlined, size: 20),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(devicesProvider.notifier)
                  .updateDeviceAlias(device.mac, controller.text);
              Navigator.of(ctx).pop();
              CustomSnackBar.showSuccess(context, 'Alias actualizado correctamente.');
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showLimitDialog(BuildContext context, WidgetRef ref, DeviceModel device) {
    final controller = TextEditingController(
      text: device.bandwidthLimitMbps != null
          ? device.bandwidthLimitMbps!.toStringAsFixed(0)
          : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        backgroundColor: Colors.white,
        title: Text('Limitar Ancho de Banda', style: AppTypography.sectionHeader),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Establece la velocidad máxima de descarga para ${device.displayName}:',
              style: AppTypography.bodyRegular.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Velocidad máxima (Mbps)',
                hintText: 'Ej: 20',
                suffixText: 'Mbps',
                prefixIcon: Icon(Icons.speed_outlined, size: 20),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          if (device.bandwidthLimitMbps != null)
            TextButton(
              onPressed: () {
                ref.read(devicesProvider.notifier).setBandwidthLimit(device.mac, null);
                Navigator.of(ctx).pop();
                CustomSnackBar.showSuccess(context, 'Límite eliminado.');
              },
              child: Text(
                'Quitar Límite',
                style: TextStyle(color: AppColors.statusDanger),
              ),
            ),
          ElevatedButton(
            onPressed: () {
              final limit = double.tryParse(controller.text.trim());
              ref.read(devicesProvider.notifier).setBandwidthLimit(device.mac, limit);
              Navigator.of(ctx).pop();
              CustomSnackBar.showSuccess(context, 'Límite de ancho de banda aplicado.');
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }
}
