import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_endpoints.dart';

/// Manages router host endpoint storage.
class ServerConfig {
  static const String _serverUrlKey = 'mikrom_router_base_url';
  static const String _demoModeKey = 'mikrom_demo_mode';

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_serverUrlKey) ?? ApiEndpoints.defaultBaseUrl;
  }

  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    // Normalize url
    var cleanUrl = url.trim();
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'http://$cleanUrl';
    }
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }
    await prefs.setString(_serverUrlKey, cleanUrl);
  }

  static Future<bool> isDemoMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_demoModeKey) ?? false;
  }

  static Future<void> setDemoMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_demoModeKey, enabled);
  }
}
