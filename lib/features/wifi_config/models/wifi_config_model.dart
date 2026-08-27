/// Model representing Wi-Fi configuration parameters.
class WifiConfigModel {
  final String ssid;
  final String password;
  final String security; // 'WPA2-PSK', 'WPA3-SAE', 'WPA2/WPA3-Mixed', 'Open'
  final String band; // '2.4 GHz', '5 GHz', 'Dual-Band'
  final String channel; // 'Auto', '1', '6', '11', '36', '40', '44', '48'
  final bool isHidden;
  final String txPower; // '100% (Alto)', '75% (Medio)', '50% (Bajo)'

  const WifiConfigModel({
    this.ssid = 'MiKROM-Secure-Net',
    this.password = 'AdminRouter2026!',
    this.security = 'WPA2/WPA3-Mixed',
    this.band = '5 GHz',
    this.channel = 'Auto',
    this.isHidden = false,
    this.txPower = '100% (Alto)',
  });

  factory WifiConfigModel.fromJson(Map<String, dynamic> json) {
    return WifiConfigModel(
      ssid: json['ssid'] as String? ?? 'MiKROM-Secure-Net',
      password: json['password'] as String? ?? '',
      security: json['security'] as String? ?? 'WPA2/WPA3-Mixed',
      band: json['band'] as String? ?? '5 GHz',
      channel: json['channel']?.toString() ?? 'Auto',
      isHidden: json['is_hidden'] as bool? ?? false,
      txPower: json['tx_power'] as String? ?? '100% (Alto)',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ssid': ssid,
      'password': password,
      'security': security,
      'band': band,
      'channel': channel,
      'is_hidden': isHidden,
      'tx_power': txPower,
    };
  }

  WifiConfigModel copyWith({
    String? ssid,
    String? password,
    String? security,
    String? band,
    String? channel,
    bool? isHidden,
    String? txPower,
  }) {
    return WifiConfigModel(
      ssid: ssid ?? this.ssid,
      password: password ?? this.password,
      security: security ?? this.security,
      band: band ?? this.band,
      channel: channel ?? this.channel,
      isHidden: isHidden ?? this.isHidden,
      txPower: txPower ?? this.txPower,
    );
  }
}
