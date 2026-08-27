import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/device_model.dart';
import '../models/network_stats_model.dart';
import '../services/network_api_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final networkApiServiceProvider = Provider<NetworkApiService>((ref) {
  final client = ref.watch(apiClientProvider);
  return NetworkApiService(client);
});

class DevicesState {
  final List<DeviceModel> devices;
  final bool isLoading;
  final bool isScanning;
  final String? errorMessage;
  final DateTime? lastScanTime;

  const DevicesState({
    this.devices = const [],
    this.isLoading = true,
    this.isScanning = false,
    this.errorMessage,
    this.lastScanTime,
  });

  DevicesState copyWith({
    List<DeviceModel>? devices,
    bool? isLoading,
    bool? isScanning,
    String? errorMessage,
    DateTime? lastScanTime,
  }) {
    return DevicesState(
      devices: devices ?? this.devices,
      isLoading: isLoading ?? this.isLoading,
      isScanning: isScanning ?? this.isScanning,
      errorMessage: errorMessage,
      lastScanTime: lastScanTime ?? this.lastScanTime,
    );
  }
}

class DevicesNotifier extends StateNotifier<DevicesState> {
  final NetworkApiService _apiService;

  DevicesNotifier(this._apiService) : super(const DevicesState()) {
    fetchDevices();
  }

  Future<void> fetchDevices({bool isManualScan = false}) async {
    if (isManualScan) {
      state = state.copyWith(isScanning: true, errorMessage: null);
      // Brief simulated scanning delay for microinteraction
      await Future.delayed(const Duration(milliseconds: 600));
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      final devices = await _apiService.getDevices();
      state = state.copyWith(
        devices: devices,
        isLoading: false,
        isScanning: false,
        lastScanTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isScanning: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> toggleDeviceBlock(String mac, bool shouldBlock) async {
    // Find device IP if available
    String? deviceIp;
    final updatedList = state.devices.map((device) {
      if (device.mac.toUpperCase() == mac.toUpperCase()) {
        deviceIp = device.ip;
        return device.copyWith(isBlocked: shouldBlock);
      }
      return device;
    }).toList();

    state = state.copyWith(devices: updatedList);

    try {
      bool success = false;
      if (shouldBlock) {
        success = await _apiService.blockMac(mac, ip: deviceIp);
      } else {
        success = await _apiService.allowMac(mac, ip: deviceIp);
      }
      return success;
    } catch (e) {
      // Revert on error
      fetchDevices();
      return false;
    }
  }

  void updateDeviceAlias(String mac, String newAlias) {
    final updatedList = state.devices.map((device) {
      if (device.mac.toUpperCase() == mac.toUpperCase()) {
        return device.copyWith(customAlias: newAlias.trim().isEmpty ? null : newAlias.trim());
      }
      return device;
    }).toList();

    state = state.copyWith(devices: updatedList);
  }

  void toggleStaticIp(String mac, bool isStatic) {
    final updatedList = state.devices.map((device) {
      if (device.mac.toUpperCase() == mac.toUpperCase()) {
        return device.copyWith(isStaticIp: isStatic);
      }
      return device;
    }).toList();

    state = state.copyWith(devices: updatedList);
  }

  void setBandwidthLimit(String mac, double? limitMbps) {
    final updatedList = state.devices.map((device) {
      if (device.mac.toUpperCase() == mac.toUpperCase()) {
        return device.copyWith(bandwidthLimitMbps: limitMbps);
      }
      return device;
    }).toList();

    state = state.copyWith(devices: updatedList);
  }

  void addManualDevice(DeviceModel newDevice) {
    final updatedList = List<DeviceModel>.from(state.devices)..add(newDevice);
    state = state.copyWith(devices: updatedList);
  }
}

final devicesProvider = StateNotifierProvider<DevicesNotifier, DevicesState>((ref) {
  final service = ref.watch(networkApiServiceProvider);
  return DevicesNotifier(service);
});

final networkStatsProvider = FutureProvider<NetworkStatsModel>((ref) async {
  final devicesState = ref.watch(devicesProvider);
  final service = ref.watch(networkApiServiceProvider);
  return await service.getNetworkStats(devicesState.devices);
});

// Search and filter providers
final deviceSearchQueryProvider = StateProvider<String>((ref) => '');
final deviceFilterTypeProvider = StateProvider<DeviceType?>((ref) => null);

final filteredDevicesProvider = Provider<List<DeviceModel>>((ref) {
  final devicesState = ref.watch(devicesProvider);
  final query = ref.watch(deviceSearchQueryProvider).toLowerCase().trim();
  final filterType = ref.watch(deviceFilterTypeProvider);

  return devicesState.devices.where((device) {
    final matchesQuery = query.isEmpty ||
        device.displayName.toLowerCase().contains(query) ||
        device.ip.contains(query) ||
        device.mac.toLowerCase().contains(query);

    final matchesType = filterType == null || device.deviceType == filterType;

    return matchesQuery && matchesType;
  }).toList();
});
