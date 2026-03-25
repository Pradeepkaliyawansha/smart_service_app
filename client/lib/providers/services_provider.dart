import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_model.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import 'auth_provider.dart';

// ─── Services list ────────────────────────────────────────────────────────────

class ServicesState {
  final List<ServiceModel> services;
  final bool isLoading;
  final String? error;
  final bool isOffline;
  final String? selectedCategory;

  const ServicesState({
    this.services = const [],
    this.isLoading = false,
    this.error,
    this.isOffline = false,
    this.selectedCategory,
  });

  List<ServiceModel> get filtered {
    if (selectedCategory == null || selectedCategory == 'All') return services;
    return services.where((s) => s.category == selectedCategory).toList();
  }

  ServicesState copyWith({
    List<ServiceModel>? services,
    bool? isLoading,
    String? error,
    bool? isOffline,
    String? selectedCategory,
    bool clearCategory = false,
  }) {
    return ServicesState(
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isOffline: isOffline ?? this.isOffline,
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
    );
  }
}

class ServicesNotifier extends StateNotifier<ServicesState> {
  final ApiService _api;

  ServicesNotifier(this._api) : super(const ServicesState()) {
    loadServices();
  }

  Future<void> loadServices({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, error: null, isOffline: false);

    // Try cache first
    if (!forceRefresh) {
      final cached = CacheService.getCachedServices();
      if (cached != null && cached.isNotEmpty) {
        state = state.copyWith(services: cached, isLoading: false);
        return;
      }
    }

    try {
      final services = await _api.getServices();
      await CacheService.cacheServices(services);
      state = state.copyWith(services: services, isLoading: false);
    } catch (e) {
      final cached = CacheService.getCachedServices();
      if (cached != null && cached.isNotEmpty) {
        state = state.copyWith(
          services: cached,
          isLoading: false,
          isOffline: true,
          error: 'Showing cached data — no internet',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load services',
          isOffline: true,
        );
      }
    }
  }

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  Future<ServiceModel> createService(Map<String, dynamic> data) async {
    final service = await _api.createService(data);
    state = state.copyWith(services: [...state.services, service]);
    return service;
  }

  Future<void> deleteService(String id) async {
    await _api.deleteService(id);
    state = state.copyWith(
      services: state.services.where((s) => s.id != id).toList(),
    );
  }
}

final servicesProvider = StateNotifierProvider<ServicesNotifier, ServicesState>(
  (ref) {
    return ServicesNotifier(ref.read(apiServiceProvider));
  },
);

// ─── Single service ───────────────────────────────────────────────────────────

final serviceDetailProvider = FutureProvider.family<ServiceModel, String>((
  ref,
  id,
) async {
  final api = ref.read(apiServiceProvider);
  return api.getService(id);
});

// ─── Popular services ─────────────────────────────────────────────────────────

final popularServicesProvider = Provider<List<ServiceModel>>((ref) {
  final services = ref.watch(servicesProvider).services;
  final sorted = [...services]
    ..sort((a, b) => b.bookingCount.compareTo(a.bookingCount));
  return sorted.take(3).toList();
});
