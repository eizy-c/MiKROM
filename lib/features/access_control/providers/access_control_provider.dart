import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/models/device_model.dart';
import '../../dashboard/providers/dashboard_provider.dart';

final blockedDevicesProvider = Provider<List<DeviceModel>>((ref) {
  final devicesState = ref.watch(devicesProvider);
  return devicesState.devices.where((d) => d.isBlocked).toList();
});

final allowedDevicesProvider = Provider<List<DeviceModel>>((ref) {
  final devicesState = ref.watch(devicesProvider);
  return devicesState.devices.where((d) => !d.isBlocked).toList();
});
