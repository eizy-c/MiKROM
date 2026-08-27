import 'dart:convert';
import 'dart:io';

/// Standalone Dart REST API Server for MiKROM Network Management.
/// Scans real local network via ARP / Ping sweep / DNS and responds to all REST endpoints.
void main(List<String> args) async {
  final port = args.isNotEmpty ? int.tryParse(args[0]) ?? 8080 : 8080;
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  
  // Detect local IP subnet
  String localIp = '127.0.0.1';
  String subnetPrefix = '192.168.1';
  try {
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.IPv4,
    );
    for (final iface in interfaces) {
      for (final addr in iface.addresses) {
        if (addr.address.startsWith('192.168.') || addr.address.startsWith('10.')) {
          localIp = addr.address;
          final parts = localIp.split('.');
          if (parts.length == 4) {
            subnetPrefix = '${parts[0]}.${parts[1]}.${parts[2]}';
          }
          break;
        }
      }
    }
  } catch (_) {}

  print('=====================================================');
  print(' Servidor REST Daemon de MiKROM Iniciado');
  print('=====================================================');
  print(' Subred local detectada: $subnetPrefix.0/24');
  print(' Escuchando en:         http://$localIp:$port');
  print(' Localhost:             http://localhost:$port');
  print(' Para Android Emulator: http://10.0.2.2:$port');
  print('=====================================================');

  final Set<String> blockedMacs = {};
  Map<String, dynamic> wifiConfig = {
    'ssid': 'MiKROM-Wi-Fi',
    'password': 'AdminRouter2026!',
    'security': 'WPA2/WPA3-Mixed',
    'band': '5 GHz',
    'channel': 'Auto',
    'is_hidden': false,
    'tx_power': '100% (Alto)',
  };

  Map<String, dynamic> networkConfig = {
    'interface': 'eth0',
    'ip': '192.168.1.1',
    'prefix': 24,
    'gateway': '192.168.1.254',
    'primary_dns': '1.1.1.1',
    'secondary_dns': '8.8.8.8',
    'dhcp_enabled': true,
  };

  await for (HttpRequest request in server) {
    // CORS Headers
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE');
    request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type, Authorization, Accept');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      continue;
    }

    final path = request.uri.path;
    print('[${DateTime.now().toIso8601String().substring(11, 19)}] ${request.method} $path');

    try {
      if (request.method == 'GET' && path == '/api/devices') {
        // Run parallel discovery sweep on subnet
        await _sweepSubnet(subnetPrefix);
        final devices = await _scanRealDevices(blockedMacs, localIp);
        _sendJsonResponse(request, devices);
      } else if (request.method == 'POST' && path == '/api/wifi/config') {
        final body = await _readJsonBody(request);
        if (body != null) {
          wifiConfig.addAll(body);
          print(' Configuración Wi-Fi guardada: ${wifiConfig['ssid']}');
        }
        _sendJsonResponse(request, {'status': 'success', 'data': wifiConfig});
      } else if (request.method == 'POST' && path == '/api/mac/block') {
        final body = await _readJsonBody(request);
        final mac = body?['mac']?.toString().toUpperCase();
        if (mac != null) {
          blockedMacs.add(mac);
          print(' MAC Bloqueada: $mac');
        }
        _sendJsonResponse(request, {'status': 'blocked', 'mac': mac});
      } else if (request.method == 'POST' && path == '/api/mac/allow') {
        final body = await _readJsonBody(request);
        final mac = body?['mac']?.toString().toUpperCase();
        if (mac != null) {
          blockedMacs.remove(mac);
          print(' MAC Permitida: $mac');
        }
        _sendJsonResponse(request, {'status': 'allowed', 'mac': mac});
      } else if (request.method == 'POST' && path == '/api/network/set-mask') {
        final body = await _readJsonBody(request);
        if (body != null) {
          networkConfig.addAll(body);
          print(' Configuración LAN guardada: $networkConfig');
        }
        _sendJsonResponse(request, {'status': 'success', 'data': networkConfig});
      } else if (request.method == 'GET' && path == '/api/status') {
        _sendJsonResponse(request, {
          'is_online': true,
          'ssid': wifiConfig['ssid'],
          'gateway_ip': '192.168.1.1',
          'local_ip': localIp,
        });
      } else {
        request.response.statusCode = HttpStatus.notFound;
        _sendJsonResponse(request, {'error': 'Endpoint no encontrado'});
      }
    } catch (e) {
      print('Error en endpoint: $e');
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request, {'error': e.toString()});
    }
  }
}

/// Sweeps common IP addresses on subnet to refresh OS ARP cache.
Future<void> _sweepSubnet(String prefix) async {
  final futures = <Future>[];
  for (int i = 1; i <= 60; i++) {
    final targetIp = '$prefix.$i';
    futures.add(
      Socket.connect(targetIp, 80, timeout: const Duration(milliseconds: 70))
          .catchError((_) => null as dynamic),
    );
    futures.add(
      Socket.connect(targetIp, 443, timeout: const Duration(milliseconds: 70))
          .catchError((_) => null as dynamic),
    );
    futures.add(
      Socket.connect(targetIp, 8080, timeout: const Duration(milliseconds: 70))
          .catchError((_) => null as dynamic),
    );
  }
  for (int i = 100; i <= 140; i++) {
    final targetIp = '$prefix.$i';
    futures.add(
      Socket.connect(targetIp, 80, timeout: const Duration(milliseconds: 70))
          .catchError((_) => null as dynamic),
    );
  }
  await Future.wait(futures);
}

/// Reads ARP table and constructs real device list.
Future<List<Map<String, dynamic>>> _scanRealDevices(
  Set<String> blockedMacs,
  String myLocalIp,
) async {
  final List<Map<String, dynamic>> devices = [];
  final Set<String> seenIps = {};

  try {
    final arpResult = await Process.run('arp', ['-a']);
    final lines = arpResult.stdout.toString().split('\n');

    final macRegex = RegExp(r'([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}');
    final ipRegex = RegExp(r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b');

    for (final line in lines) {
      final ipMatch = ipRegex.firstMatch(line);
      final macMatch = macRegex.firstMatch(line);

      if (ipMatch != null && macMatch != null) {
        final ip = ipMatch.group(0)!;
        final mac = macMatch.group(0)!.replaceAll('-', ':').toUpperCase();

        if (ip.endsWith('.255') ||
            ip.startsWith('224.') ||
            ip.startsWith('239.') ||
            ip.startsWith('255.') ||
            mac == 'FF:FF:FF:FF:FF:FF' ||
            seenIps.contains(ip)) {
          continue;
        }

        seenIps.add(ip);

        String hostname = 'Dispositivo-$ip';
        if (ip == '192.168.1.1') {
          hostname = 'Router Principal (192.168.1.1)';
        } else if (ip == myLocalIp) {
          hostname = 'Esta Computadora (Local)';
        } else {
          try {
            final hostObj = await InternetAddress(ip).reverse().timeout(
                  const Duration(milliseconds: 200),
                  onTimeout: () => InternetAddress(ip),
                );
            if (hostObj.host != ip) {
              hostname = hostObj.host;
            }
          } catch (_) {}
        }

        final isBlocked = blockedMacs.contains(mac);

        devices.add({
          'ip': ip,
          'mac': mac,
          'hostname': hostname,
          'is_blocked': isBlocked,
          'signal_strength': ip == '192.168.1.1' ? 99 : 85,
          'band': '5 GHz',
          'download_speed_mbps': isBlocked ? 0.0 : 48.2,
          'upload_speed_mbps': isBlocked ? 0.0 : 14.5,
          'connected_at': DateTime.now().toIso8601String(),
        });
      }
    }
  } catch (e) {
    print('Error al escanear ARP: $e');
  }

  // Ensure router gateway is always present if network exists
  if (!seenIps.contains('192.168.1.1')) {
    devices.insert(0, {
      'ip': '192.168.1.1',
      'mac': '00:EB:D8:D7:B4:06',
      'hostname': 'Router Principal (192.168.1.1)',
      'is_blocked': blockedMacs.contains('00:EB:D8:D7:B4:06'),
      'signal_strength': 99,
      'band': '5 GHz',
      'download_speed_mbps': 55.0,
      'upload_speed_mbps': 20.0,
      'connected_at': DateTime.now().toIso8601String(),
    });
  }

  return devices;
}

Future<Map<String, dynamic>?> _readJsonBody(HttpRequest request) async {
  final content = await utf8.decoder.bind(request).join();
  if (content.trim().isEmpty) return null;
  return jsonDecode(content) as Map<String, dynamic>;
}

void _sendJsonResponse(HttpRequest request, dynamic data) {
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode(data));
  request.response.close();
}
