import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../dashboard/services/network_api_service.dart';
import '../models/wifi_config_model.dart';

class WifiConfigState {
  final WifiConfigModel config;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final bool isSuccess;

  const WifiConfigState({
    this.config = const WifiConfigModel(),
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  WifiConfigState copyWith({
    WifiConfigModel? config,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return WifiConfigState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class WifiConfigNotifier extends StateNotifier<WifiConfigState> {
  final NetworkApiService _apiService;

  WifiConfigNotifier(this._apiService) : super(const WifiConfigState()) {
    loadConfig();
  }

  Future<void> loadConfig() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final config = await _apiService.getWifiConfig();
      state = state.copyWith(config: config, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> saveConfig(WifiConfigModel newConfig) async {
    state = state.copyWith(isSaving: true, errorMessage: null, isSuccess: false);
    try {
      final ok = await _apiService.setWifiConfig(newConfig);
      state = state.copyWith(
        config: newConfig,
        isSaving: false,
        isSuccess: ok,
      );
      return ok;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
      return false;
    }
  }
}

final wifiConfigProvider =
    StateNotifierProvider<WifiConfigNotifier, WifiConfigState>((ref) {
  final service = ref.watch(networkApiServiceProvider);
  return WifiConfigNotifier(service);
});
