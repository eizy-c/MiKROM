import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/server_config.dart';

class ServerSettingsState {
  final String baseUrl;
  final bool isDemoMode;
  final bool isConnecting;
  final String? connectionError;

  const ServerSettingsState({
    this.baseUrl = ApiEndpoints.defaultBaseUrl,
    this.isDemoMode = false,
    this.isConnecting = false,
    this.connectionError,
  });

  ServerSettingsState copyWith({
    String? baseUrl,
    bool? isDemoMode,
    bool? isConnecting,
    String? connectionError,
  }) {
    return ServerSettingsState(
      baseUrl: baseUrl ?? this.baseUrl,
      isDemoMode: isDemoMode ?? this.isDemoMode,
      isConnecting: isConnecting ?? this.isConnecting,
      connectionError: connectionError,
    );
  }
}

class ServerSettingsNotifier extends StateNotifier<ServerSettingsState> {
  ServerSettingsNotifier() : super(const ServerSettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final url = await ServerConfig.getBaseUrl();
    final demo = await ServerConfig.isDemoMode();
    state = state.copyWith(baseUrl: url, isDemoMode: demo);
  }

  Future<void> updateBaseUrl(String newUrl) async {
    await ServerConfig.setBaseUrl(newUrl);
    final clean = await ServerConfig.getBaseUrl();
    state = state.copyWith(baseUrl: clean, connectionError: null);
  }

  Future<void> toggleDemoMode(bool enabled) async {
    await ServerConfig.setDemoMode(enabled);
    state = state.copyWith(isDemoMode: enabled);
  }
}

final serverSettingsProvider =
    StateNotifierProvider<ServerSettingsNotifier, ServerSettingsState>(
  (ref) => ServerSettingsNotifier(),
);
