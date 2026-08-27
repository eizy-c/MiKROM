import '../../../core/utils/ip_utils.dart';

/// Network Adapter / Subnet Mask configuration model.
class AdapterConfigModel {
  final String interfaceName;
  final String ip;
  final int prefix; // CIDR e.g. 24
  final String gateway;
  final String primaryDns;
  final String secondaryDns;
  final bool dhcpEnabled;

  const AdapterConfigModel({
    this.interfaceName = 'eth0',
    this.ip = '192.168.1.1',
    this.prefix = 24,
    this.gateway = '192.168.1.254',
    this.primaryDns = '1.1.1.1',
    this.secondaryDns = '8.8.8.8',
    this.dhcpEnabled = true,
  });

  String get subnetMask => IpUtils.cidrToSubnetMask(prefix);
  int get maxHosts => IpUtils.hostCountForPrefix(prefix);

  factory AdapterConfigModel.fromJson(Map<String, dynamic> json) {
    return AdapterConfigModel(
      interfaceName: json['interface'] as String? ?? 'eth0',
      ip: json['ip'] as String? ?? '192.168.1.1',
      prefix: json['prefix'] as int? ?? 24,
      gateway: json['gateway'] as String? ?? '192.168.1.254',
      primaryDns: json['primary_dns'] as String? ?? '1.1.1.1',
      secondaryDns: json['secondary_dns'] as String? ?? '8.8.8.8',
      dhcpEnabled: json['dhcp_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interface': interfaceName,
      'ip': ip,
      'prefix': prefix,
      'gateway': gateway,
      'primary_dns': primaryDns,
      'secondary_dns': secondaryDns,
      'dhcp_enabled': dhcpEnabled,
    };
  }

  AdapterConfigModel copyWith({
    String? interfaceName,
    String? ip,
    int? prefix,
    String? gateway,
    String? primaryDns,
    String? secondaryDns,
    bool? dhcpEnabled,
  }) {
    return AdapterConfigModel(
      interfaceName: interfaceName ?? this.interfaceName,
      ip: ip ?? this.ip,
      prefix: prefix ?? this.prefix,
      gateway: gateway ?? this.gateway,
      primaryDns: primaryDns ?? this.primaryDns,
      secondaryDns: secondaryDns ?? this.secondaryDns,
      dhcpEnabled: dhcpEnabled ?? this.dhcpEnabled,
    );
  }
}
