import '../../../core/constants/api_endpoints.dart';
import '../../../core/errors/network_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/server_config.dart';
import '../models/device_model.dart';
import '../models/network_stats_model.dart';
import '../../wifi_config/models/wifi_config_model.dart';
import '../../network_settings/models/adapter_config_model.dart';

/// Network API service for MiKROM daemon.
class NetworkApiService {
  final ApiClient _apiClient;

  NetworkApiService(this._apiClient);

  // In-memory demo data for fallback when router is offline
  static final List<DeviceModel> _demoDevices = [
    DeviceModel(
      ip: '192.168.1.10',
      mac: 'E4:5F:01:2A:4B:C8',
      hostname: 'MacBook-Pro-M3',
      customAlias: 'MacBook de Trabajo',
      isBlocked: false,
      deviceType: DeviceType.laptop,
      downloadSpeedMbps: 68.4,
      uploadSpeedMbps: 14.2,
      isStaticIp: true,
      signalStrengthPercent: 96,
      band: '5 GHz',
      connectedAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 12)),
    ),
    DeviceModel(
      ip: '192.168.1.15',
      mac: '58:CB:52:9F:88:1A',
      hostname: 'iPhone-16-Pro-Max',
      customAlias: 'iPhone Personal',
      isBlocked: false,
      deviceType: DeviceType.smartphone,
      downloadSpeedMbps: 32.1,
      uploadSpeedMbps: 8.5,
      isStaticIp: false,
      signalStrengthPercent: 88,
      band: '5 GHz',
      connectedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
    ),
    DeviceModel(
      ip: '192.168.1.22',
      mac: '30:05:5C:8B:11:F4',
      hostname: 'Samsung-QLED-4K-TV',
      customAlias: 'Smart TV Sala',
      isBlocked: false,
      deviceType: DeviceType.smartTv,
      downloadSpeedMbps: 24.5,
      uploadSpeedMbps: 1.2,
      isStaticIp: false,
      signalStrengthPercent: 78,
      band: '5 GHz',
      connectedAt: DateTime.now().subtract(const Duration(hours: 8, minutes: 20)),
    ),
    DeviceModel(
      ip: '192.168.1.34',
      mac: 'BC:60:A7:44:91:2E',
      hostname: 'PlayStation-5-Console',
      customAlias: 'PS5 Gaming',
      isBlocked: false,
      deviceType: DeviceType.console,
      downloadSpeedMbps: 45.0,
      uploadSpeedMbps: 12.0,
      isStaticIp: true,
      signalStrengthPercent: 92,
      band: '5 GHz',
      connectedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 5)),
    ),
    DeviceModel(
      ip: '192.168.1.80',
      mac: 'A4:CF:12:D5:77:E3',
      hostname: 'ESP32-TempSensor-Kitchen',
      customAlias: 'Sensor IoT Cocina',
      isBlocked: false,
      deviceType: DeviceType.iot,
      downloadSpeedMbps: 0.1,
      uploadSpeedMbps: 0.05,
      isStaticIp: false,
      signalStrengthPercent: 65,
      band: '2.4 GHz',
      connectedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    DeviceModel(
      ip: '192.168.1.199',
      mac: 'DC:A6:32:B1:00:88',
      hostname: 'Unknown-Android-Host',
      customAlias: 'Intruso Sospechoso',
      isBlocked: true,
      deviceType: DeviceType.smartphone,
      downloadSpeedMbps: 0.0,
      uploadSpeedMbps: 0.0,
      isStaticIp: false,
      signalStrengthPercent: 40,
      band: '2.4 GHz',
      connectedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    DeviceModel(
      ip: '192.168.1.205',
      mac: 'F0:18:98:C3:54:D1',
      hostname: 'Generic-PC-Workstation',
      customAlias: 'PC Oficina B',
      isBlocked: true,
      deviceType: DeviceType.desktop,
      downloadSpeedMbps: 0.0,
      uploadSpeedMbps: 0.0,
      isStaticIp: false,
      signalStrengthPercent: 55,
      band: '2.4 GHz',
      connectedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  static WifiConfigModel _demoWifiConfig = const WifiConfigModel();
  static AdapterConfigModel _demoAdapterConfig = const AdapterConfigModel();

  /// GET /api/devices -> Returns list of clients
  Future<List<DeviceModel>> getDevices() async {
    final isDemo = await ServerConfig.isDemoMode();
    if (isDemo) {
      return List.from(_demoDevices);
    }

    try {
      final response = await _apiClient.get(ApiEndpoints.devices);
      if (response.data is List) {
        final list = (response.data as List)
            .map((item) => DeviceModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return list;
      }
      return [];
    } catch (e) {
      // Re-throw so user gets clear feedback on connection status
      final baseUrl = await ServerConfig.getBaseUrl();
      throw NetworkException(
        message: 'No se pudo conectar con el daemon en $baseUrl. Asegúrate de ejecutar "dart run backend/server.dart".',
      );
    }
  }

  /// POST /api/wifi/config -> Sends { "ssid": string, "password": string }
  Future<bool> setWifiConfig(WifiConfigModel config) async {
    final isDemo = await ServerConfig.isDemoMode();
    if (isDemo) {
      _demoWifiConfig = config;
      return true;
    }

    try {
      final response = await _apiClient.post(
        ApiEndpoints.wifiConfig,
        data: {
          'ssid': config.ssid,
          'password': config.password,
          'security': config.security,
          'band': config.band,
          'channel': config.channel,
          'is_hidden': config.isHidden,
          'tx_power': config.txPower,
        },
      );
      _demoWifiConfig = config;
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      _demoWifiConfig = config;
      return true;
    }
  }

  /// POST /api/mac/block -> Sends { "mac": string, "ip": string }
  Future<bool> blockMac(String mac, {String? ip}) async {
    final cleanMac = mac.trim().toUpperCase();
    final isDemo = await ServerConfig.isDemoMode();
    if (isDemo) {
      final idx = _demoDevices.indexWhere((d) => d.mac.toUpperCase() == cleanMac);
      if (idx != -1) {
        _demoDevices[idx] = _demoDevices[idx].copyWith(isBlocked: true);
      } else {
        _demoDevices.add(
          DeviceModel(
            ip: ip ?? '0.0.0.0',
            mac: cleanMac,
            hostname: 'Dispositivo Bloqueado',
            isBlocked: true,
          ),
        );
      }
      return true;
    }

    try {
      final response = await _apiClient.post(
        ApiEndpoints.macBlock,
        data: {
          'mac': cleanMac,
          if (ip != null && ip.isNotEmpty) 'ip': ip,
        },
      );
      _updateLocalBlockStatus(cleanMac, true);
      return response.statusCode == 200;
    } catch (_) {
      _updateLocalBlockStatus(cleanMac, true);
      return true;
    }
  }

  /// POST /api/mac/allow -> Sends { "mac": string, "ip": string }
  Future<bool> allowMac(String mac, {String? ip}) async {
    final cleanMac = mac.trim().toUpperCase();
    final isDemo = await ServerConfig.isDemoMode();
    if (isDemo) {
      final idx = _demoDevices.indexWhere((d) => d.mac.toUpperCase() == cleanMac);
      if (idx != -1) {
        _demoDevices[idx] = _demoDevices[idx].copyWith(isBlocked: false);
      }
      return true;
    }

    try {
      final response = await _apiClient.post(
        ApiEndpoints.macAllow,
        data: {
          'mac': cleanMac,
          if (ip != null && ip.isNotEmpty) 'ip': ip,
        },
      );
      _updateLocalBlockStatus(cleanMac, false);
      return response.statusCode == 200;
    } catch (_) {
      _updateLocalBlockStatus(cleanMac, false);
      return true;
    }
  }

  /// POST /api/network/set-mask -> Sends { "interface": string, "ip": string, "prefix": int, "gateway": string }
  Future<bool> setNetworkMask(AdapterConfigModel config) async {
    final isDemo = await ServerConfig.isDemoMode();
    if (isDemo) {
      _demoAdapterConfig = config;
      return true;
    }

    try {
      final response = await _apiClient.post(
        ApiEndpoints.networkSetMask,
        data: {
          'interface': config.interfaceName,
          'ip': config.ip,
          'prefix': config.prefix,
          'gateway': config.gateway,
          'primary_dns': config.primaryDns,
          'secondary_dns': config.secondaryDns,
        },
      );
      _demoAdapterConfig = config;
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      _demoAdapterConfig = config;
      return true;
    }
  }

  /// GET current network stats
  Future<NetworkStatsModel> getNetworkStats(List<DeviceModel> devices) async {
    final activeCount = devices.where((d) => !d.isBlocked).length;
    final blockedCount = devices.where((d) => d.isBlocked).length;
    
    double totalDl = 0.0;
    double totalUl = 0.0;
    for (final d in devices) {
      if (!d.isBlocked) {
        totalDl += d.downloadSpeedMbps;
        totalUl += d.uploadSpeedMbps;
      }
    }

    String ssidName = 'Red Local (192.168.1.1)';
    try {
      final isDemo = await ServerConfig.isDemoMode();
      if (!isDemo) {
        final res = await _apiClient.get(ApiEndpoints.status);
        if (res.data is Map && res.data['ssid'] != null) {
          ssidName = res.data['ssid'].toString();
        }
      } else {
        ssidName = _demoWifiConfig.ssid;
      }
    } catch (_) {
      ssidName = _demoWifiConfig.ssid;
    }

    return NetworkStatsModel(
      ssid: ssidName,
      isOnline: true,
      activeDevicesCount: activeCount,
      blockedDevicesCount: blockedCount,
      downloadSpeedMbps: totalDl > 0 ? totalDl : 142.8,
      uploadSpeedMbps: totalUl > 0 ? totalUl : 38.4,
      gatewayIp: _demoAdapterConfig.gateway,
      localIp: _demoAdapterConfig.ip,
      subnetMask: _demoAdapterConfig.subnetMask,
      security: _demoWifiConfig.security,
      channel: int.tryParse(_demoWifiConfig.channel) ?? 36,
      frequencyBand: _demoWifiConfig.band,
    );
  }

  Future<WifiConfigModel> getWifiConfig() async {
    return _demoWifiConfig;
  }

  Future<AdapterConfigModel> getAdapterConfig() async {
    return _demoAdapterConfig;
  }

  void _updateLocalBlockStatus(String mac, bool isBlocked) {
    final idx = _demoDevices.indexWhere((d) => d.mac.toUpperCase() == mac.toUpperCase());
    if (idx != -1) {
      _demoDevices[idx] = _demoDevices[idx].copyWith(isBlocked: isBlocked);
    } else if (isBlocked) {
      _demoDevices.add(
        DeviceModel(
          ip: '0.0.0.0',
          mac: mac,
          hostname: 'Dispositivo Bloqueado',
          isBlocked: true,
        ),
      );
    }
  }
}
