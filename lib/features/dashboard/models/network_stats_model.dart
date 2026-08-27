/// Statistics for dashboard header and traffic summary.
class NetworkStatsModel {
  final String ssid;
  final bool isOnline;
  final int activeDevicesCount;
  final int blockedDevicesCount;
  final double downloadSpeedMbps;
  final double uploadSpeedMbps;
  final String gatewayIp;
  final String localIp;
  final String subnetMask;
  final String security;
  final int channel;
  final String frequencyBand;
  final Duration uptime;

  const NetworkStatsModel({
    this.ssid = 'MiKROM-Secure-Net',
    this.isOnline = true,
    this.activeDevicesCount = 0,
    this.blockedDevicesCount = 0,
    this.downloadSpeedMbps = 142.8,
    this.uploadSpeedMbps = 38.4,
    this.gatewayIp = '192.168.1.1',
    this.localIp = '192.168.1.1',
    this.subnetMask = '255.255.255.0',
    this.security = 'WPA2/WPA3-Personal',
    this.channel = 36,
    this.frequencyBand = '5 GHz / 2.4 GHz',
    this.uptime = const Duration(days: 4, hours: 14, minutes: 22),
  });

  int get totalDevicesCount => activeDevicesCount + blockedDevicesCount;

  factory NetworkStatsModel.fromJson(Map<String, dynamic> json) {
    return NetworkStatsModel(
      ssid: json['ssid'] as String? ?? 'MiKROM-Secure-Net',
      isOnline: json['is_online'] as bool? ?? true,
      activeDevicesCount: json['active_devices_count'] as int? ?? 0,
      blockedDevicesCount: json['blocked_devices_count'] as int? ?? 0,
      downloadSpeedMbps: (json['download_speed_mbps'] as num?)?.toDouble() ?? 0.0,
      uploadSpeedMbps: (json['upload_speed_mbps'] as num?)?.toDouble() ?? 0.0,
      gatewayIp: json['gateway_ip'] as String? ?? '192.168.1.1',
      localIp: json['local_ip'] as String? ?? '192.168.1.1',
      subnetMask: json['subnet_mask'] as String? ?? '255.255.255.0',
      security: json['security'] as String? ?? 'WPA2/WPA3-Personal',
      channel: json['channel'] as int? ?? 36,
      frequencyBand: json['frequency_band'] as String? ?? '5 GHz',
      uptime: Duration(seconds: json['uptime_seconds'] as int? ?? 360000),
    );
  }

  NetworkStatsModel copyWith({
    String? ssid,
    bool? isOnline,
    int? activeDevicesCount,
    int? blockedDevicesCount,
    double? downloadSpeedMbps,
    double? uploadSpeedMbps,
    String? gatewayIp,
    String? localIp,
    String? subnetMask,
    String? security,
    int? channel,
    String? frequencyBand,
    Duration? uptime,
  }) {
    return NetworkStatsModel(
      ssid: ssid ?? this.ssid,
      isOnline: isOnline ?? this.isOnline,
      activeDevicesCount: activeDevicesCount ?? this.activeDevicesCount,
      blockedDevicesCount: blockedDevicesCount ?? this.blockedDevicesCount,
      downloadSpeedMbps: downloadSpeedMbps ?? this.downloadSpeedMbps,
      uploadSpeedMbps: uploadSpeedMbps ?? this.uploadSpeedMbps,
      gatewayIp: gatewayIp ?? this.gatewayIp,
      localIp: localIp ?? this.localIp,
      subnetMask: subnetMask ?? this.subnetMask,
      security: security ?? this.security,
      channel: channel ?? this.channel,
      frequencyBand: frequencyBand ?? this.frequencyBand,
      uptime: uptime ?? this.uptime,
    );
  }
}
