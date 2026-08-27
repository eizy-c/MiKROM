/// Input validators for networking and configuration forms.
class Validators {
  Validators._();

  // MAC Address Regex specified in requirement: ^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$
  static final RegExp _macRegex = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
  static final RegExp _ipv4Regex = RegExp(r'^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$');

  /// Validates MAC address format (e.g. AA:BB:CC:DD:EE:FF or AA-BB-CC-DD-EE-FF).
  static String? validateMac(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La dirección MAC es obligatoria';
    }
    final clean = value.trim();
    if (!_macRegex.hasMatch(clean)) {
      return 'Formato MAC inválido (Ej: AA:BB:CC:DD:EE:FF)';
    }
    return null;
  }

  /// Validates standard IPv4 address.
  static String? validateIPv4(String? value, {String fieldName = 'Dirección IP'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerida';
    }
    final clean = value.trim();
    if (!_ipv4Regex.hasMatch(clean)) {
      return '$fieldName no tiene un formato válido (Ej: 192.168.1.1)';
    }
    return null;
  }

  /// Validates SSID network name.
  static String? validateSsid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre de red (SSID) no puede estar vacío';
    }
    if (value.length < 2 || value.length > 32) {
      return 'El SSID debe tener entre 2 y 32 caracteres';
    }
    return null;
  }

  /// Validates Wi-Fi password (WPA2/WPA3 min 8 chars).
  static String? validateWifiPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 8 || value.length > 63) {
      return 'La contraseña debe contener entre 8 y 63 caracteres';
    }
    return null;
  }

  /// Validates CIDR prefix (0 to 32).
  static String? validatePrefix(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Prefijo CIDR requerido';
    }
    final prefix = int.tryParse(value.trim());
    if (prefix == null || prefix < 0 || prefix > 32) {
      return 'El prefijo debe ser un entero entre 0 y 32 (Ej: 24)';
    }
    return null;
  }
}
