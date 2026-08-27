import 'package:flutter/material.dart';

enum DeviceType {
  smartphone,
  laptop,
  desktop,
  console,
  smartTv,
  iot,
  printer,
  generic,
}

/// Model representing a connected host in the local network.
class DeviceModel {
  final String ip;
  final String mac;
  final String hostname;
  final bool isBlocked;
  final String? customAlias;
  final DeviceType deviceType;
  final double downloadSpeedMbps;
  final double uploadSpeedMbps;
  final bool isStaticIp;
  final double? bandwidthLimitMbps;
  final int signalStrengthPercent; // 0 - 100
  final String band; // '2.4 GHz' or '5 GHz'
  final DateTime? connectedAt;

  const DeviceModel({
    required this.ip,
    required this.mac,
    required this.hostname,
    required this.isBlocked,
    this.customAlias,
    this.deviceType = DeviceType.generic,
    this.downloadSpeedMbps = 0.0,
    this.uploadSpeedMbps = 0.0,
    this.isStaticIp = false,
    this.bandwidthLimitMbps,
    this.signalStrengthPercent = 85,
    this.band = '5 GHz',
    this.connectedAt,
  });

  String get displayName {
    if (customAlias != null && customAlias!.trim().isNotEmpty) {
      return customAlias!;
    }
    if (hostname.isNotEmpty) {
      return hostname;
    }
    return ip;
  }

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    final hostname = json['hostname'] as String? ?? 'Dispositivo Desconocido';
    final isBlocked = json['is_blocked'] as bool? ?? false;
    final ip = json['ip'] as String? ?? '0.0.0.0';
    final mac = json['mac'] as String? ?? '00:00:00:00:00:00';

    return DeviceModel(
      ip: ip,
      mac: mac,
      hostname: hostname,
      isBlocked: isBlocked,
      customAlias: json['custom_alias'] as String?,
      deviceType: _detectDeviceType(hostname, json['device_type'] as String?),
      downloadSpeedMbps: (json['download_speed_mbps'] as num?)?.toDouble() ?? 0.0,
      uploadSpeedMbps: (json['upload_speed_mbps'] as num?)?.toDouble() ?? 0.0,
      isStaticIp: json['is_static_ip'] as bool? ?? false,
      bandwidthLimitMbps: (json['bandwidth_limit_mbps'] as num?)?.toDouble(),
      signalStrengthPercent: json['signal_strength'] as int? ?? 85,
      band: json['band'] as String? ?? '5 GHz',
      connectedAt: json['connected_at'] != null
          ? DateTime.tryParse(json['connected_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ip': ip,
      'mac': mac,
      'hostname': hostname,
      'is_blocked': isBlocked,
      'custom_alias': customAlias,
      'device_type': deviceType.name,
      'download_speed_mbps': downloadSpeedMbps,
      'upload_speed_mbps': uploadSpeedMbps,
      'is_static_ip': isStaticIp,
      'bandwidth_limit_mbps': bandwidthLimitMbps,
      'signal_strength': signalStrengthPercent,
      'band': band,
      'connected_at': connectedAt?.toIso8601String(),
    };
  }

  DeviceModel copyWith({
    String? ip,
    String? mac,
    String? hostname,
    bool? isBlocked,
    String? customAlias,
    DeviceType? deviceType,
    double? downloadSpeedMbps,
    double? uploadSpeedMbps,
    bool? isStaticIp,
    double? bandwidthLimitMbps,
    int? signalStrengthPercent,
    String? band,
    DateTime? connectedAt,
  }) {
    return DeviceModel(
      ip: ip ?? this.ip,
      mac: mac ?? this.mac,
      hostname: hostname ?? this.hostname,
      isBlocked: isBlocked ?? this.isBlocked,
      customAlias: customAlias ?? this.customAlias,
      deviceType: deviceType ?? this.deviceType,
      downloadSpeedMbps: downloadSpeedMbps ?? this.downloadSpeedMbps,
      uploadSpeedMbps: uploadSpeedMbps ?? this.uploadSpeedMbps,
      isStaticIp: isStaticIp ?? this.isStaticIp,
      bandwidthLimitMbps: bandwidthLimitMbps ?? this.bandwidthLimitMbps,
      signalStrengthPercent:
          signalStrengthPercent ?? this.signalStrengthPercent,
      band: band ?? this.band,
      connectedAt: connectedAt ?? this.connectedAt,
    );
  }

  static DeviceType _detectDeviceType(String hostname, String? typeHint) {
    if (typeHint != null) {
      for (final type in DeviceType.values) {
        if (type.name.toLowerCase() == typeHint.toLowerCase()) {
          return type;
        }
      }
    }
    final lower = hostname.toLowerCase();
    if (lower.contains('iphone') ||
        lower.contains('galaxy') ||
        lower.contains('pixel') ||
        lower.contains('phone') ||
        lower.contains('redmi') ||
        lower.contains('xiaomi') ||
        lower.contains('android')) {
      return DeviceType.smartphone;
    }
    if (lower.contains('macbook') ||
        lower.contains('laptop') ||
        lower.contains('thinkpad') ||
        lower.contains('zenbook') ||
        lower.contains('dell-xps')) {
      return DeviceType.laptop;
    }
    if (lower.contains('playstation') ||
        lower.contains('ps5') ||
        lower.contains('ps4') ||
        lower.contains('xbox') ||
        lower.contains('switch') ||
        lower.contains('nintendo')) {
      return DeviceType.console;
    }
    if (lower.contains('tv') ||
        lower.contains('roku') ||
        lower.contains('chromecast') ||
        lower.contains('firestick') ||
        lower.contains('samsung-tv') ||
        lower.contains('lg-tv')) {
      return DeviceType.smartTv;
    }
    if (lower.contains('printer') || lower.contains('epson') || lower.contains('hp-laser')) {
      return DeviceType.printer;
    }
    if (lower.contains('esp') ||
        lower.contains('arduino') ||
        lower.contains('tasmota') ||
        lower.contains('sonoff') ||
        lower.contains('shelly') ||
        lower.contains('cam') ||
        lower.contains('alexa') ||
        lower.contains('echo') ||
        lower.contains('nest')) {
      return DeviceType.iot;
    }
    if (lower.contains('desktop') || lower.contains('pc') || lower.contains('workstation')) {
      return DeviceType.desktop;
    }
    return DeviceType.generic;
  }

  IconData get iconData {
    return switch (deviceType) {
      DeviceType.smartphone => Icons.smartphone,
      DeviceType.laptop => Icons.laptop_mac,
      DeviceType.desktop => Icons.desktop_windows,
      DeviceType.console => Icons.sports_esports,
      DeviceType.smartTv => Icons.tv,
      DeviceType.printer => Icons.print,
      DeviceType.iot => Icons.memory,
      DeviceType.generic => Icons.devices_other,
    };
  }
}
