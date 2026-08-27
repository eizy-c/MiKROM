import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../dashboard/services/network_api_service.dart';
import '../models/adapter_config_model.dart';

class NetworkSettingsState {
  final AdapterConfigModel config;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final bool isSuccess;

  const NetworkSettingsState({
    this.config = const AdapterConfigModel(),
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  NetworkSettingsState copyWith({
    AdapterConfigModel? config,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return NetworkSettingsState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class NetworkSettingsNotifier extends StateNotifier<NetworkSettingsState> {
  final NetworkApiService _apiService;

  NetworkSettingsNotifier(this._apiService) : super(const NetworkSettingsState()) {
    loadConfig();
  }

  Future<void> loadConfig() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final config = await _apiService.getAdapterConfig();
      state = state.copyWith(config: config, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> saveConfig(AdapterConfigModel newConfig) async {
    state = state.copyWith(isSaving: true, errorMessage: null, isSuccess: false);
    try {
      final ok = await _apiService.setNetworkMask(newConfig);
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

final networkSettingsProvider =
    StateNotifierProvider<NetworkSettingsNotifier, NetworkSettingsState>((ref) {
  final service = ref.watch(networkApiServiceProvider);
  return NetworkSettingsNotifier(service);
});
