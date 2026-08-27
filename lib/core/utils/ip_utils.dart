/// Utilities for IP and Subnet Mask conversions (CIDR <-> Dotted Decimal).
class IpUtils {
  IpUtils._();

  /// Converts a CIDR prefix (e.g. 24) to a dotted-decimal subnet mask (e.g. 255.255.255.0).
  static String cidrToSubnetMask(int prefix) {
    if (prefix < 0) prefix = 0;
    if (prefix > 32) prefix = 32;

    int mask = (prefix == 0) ? 0 : (0xFFFFFFFF << (32 - prefix)) & 0xFFFFFFFF;
    int octet1 = (mask >> 24) & 0xFF;
    int octet2 = (mask >> 16) & 0xFF;
    int octet3 = (mask >> 8) & 0xFF;
    int octet4 = mask & 0xFF;

    return '$octet1.$octet2.$octet3.$octet4';
  }

  /// Converts a dotted-decimal subnet mask (e.g. 255.255.255.0) to CIDR prefix (e.g. 24).
  static int subnetMaskToCidr(String mask) {
    try {
      final parts = mask.trim().split('.');
      if (parts.length != 4) return 24;

      int binary = 0;
      for (final part in parts) {
        final octet = int.parse(part);
        if (octet < 0 || octet > 255) return 24;
        binary = (binary << 8) | octet;
      }

      int count = 0;
      for (int i = 31; i >= 0; i--) {
        if ((binary & (1 << i)) != 0) {
          count++;
        } else {
          break;
        }
      }
      return count;
    } catch (_) {
      return 24;
    }
  }

  /// Calculates usable host count for a given CIDR prefix.
  static int hostCountForPrefix(int prefix) {
    if (prefix >= 31) return 2;
    return (1 << (32 - prefix)) - 2;
  }
}
