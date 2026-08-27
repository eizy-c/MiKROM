/// REST API Endpoints for local router daemon / backend.
class ApiEndpoints {
  ApiEndpoints._();

  static const String defaultBaseUrl = 'http://192.168.1.1:8080';
  
  // Endpoints defined in specification
  static const String devices = '/api/devices';
  static const String wifiConfig = '/api/wifi/config';
  static const String macBlock = '/api/mac/block';
  static const String macAllow = '/api/mac/allow';
  static const String networkSetMask = '/api/network/set-mask';
  static const String status = '/api/status';
  static const String reboot = '/api/system/reboot';
}
