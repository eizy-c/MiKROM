/// Formatting utilities for speeds, bytes, and MAC addresses.
class Formatters {
  Formatters._();

  /// Formats speed in bps/kbps/Mbps/Gbps
  static String formatSpeed(double mbps) {
    if (mbps >= 1000) {
      return '${(mbps / 1000).toStringAsFixed(1)} Gbps';
    } else if (mbps >= 1) {
      return '${mbps.toStringAsFixed(1)} Mbps';
    } else {
      return '${(mbps * 1000).toStringAsFixed(0)} Kbps';
    }
  }

  /// Formats bytes into human readable format (KB, MB, GB).
  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Normalizes MAC address string to uppercase with colons.
  static String normalizeMac(String mac) {
    return mac.trim().replaceAll('-', ':').toUpperCase();
  }
}
