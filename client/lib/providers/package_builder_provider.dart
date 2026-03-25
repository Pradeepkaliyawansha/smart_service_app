import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_model.dart';
import '../models/addon_model.dart';
import '../models/price_calculation_model.dart';
import '../services/price_calculator_service.dart';
import '../services/cache_service.dart';
import 'auth_provider.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class PackageBuilderState {
  final ServiceModel? service;
  final List<AddonModel> availableAddons;
  final Set<String> selectedAddonIds;
  final int durationHours;
  final PriceCalculation? pricing;
  final bool isCalculating;
  final String? error;

  const PackageBuilderState({
    this.service,
    this.availableAddons = const [],
    this.selectedAddonIds = const {},
    this.durationHours = 2,
    this.pricing,
    this.isCalculating = false,
    this.error,
  });

  List<AddonModel> get selectedAddons =>
      availableAddons.where((a) => selectedAddonIds.contains(a.id)).toList();

  bool isAddonSelected(String id) => selectedAddonIds.contains(id);

  PackageBuilderState copyWith({
    ServiceModel? service,
    List<AddonModel>? availableAddons,
    Set<String>? selectedAddonIds,
    int? durationHours,
    PriceCalculation? pricing,
    bool? isCalculating,
    String? error,
  }) {
    return PackageBuilderState(
      service: service ?? this.service,
      availableAddons: availableAddons ?? this.availableAddons,
      selectedAddonIds: selectedAddonIds ?? this.selectedAddonIds,
      durationHours: durationHours ?? this.durationHours,
      pricing: pricing ?? this.pricing,
      isCalculating: isCalculating ?? this.isCalculating,
      error: error,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class PackageBuilderNotifier extends StateNotifier<PackageBuilderState> {
  PackageBuilderNotifier() : super(const PackageBuilderState());

  void setService(ServiceModel service) {
    state = PackageBuilderState(
      service: service,
      availableAddons: service.addons,
      durationHours: service.minHours,
    );
    _recalculate();
  }

  void toggleAddon(String addonId) {
    final newSelected = Set<String>.from(state.selectedAddonIds);
    if (newSelected.contains(addonId)) {
      newSelected.remove(addonId);
    } else {
      newSelected.add(addonId);
    }
    state = state.copyWith(selectedAddonIds: newSelected);
    _recalculate();
  }

  void setDuration(int hours) {
    state = state.copyWith(durationHours: hours);
    _recalculate();
  }

  void _recalculate() {
    final service = state.service;
    if (service == null) return;

    final pricing = PriceCalculatorService.calculate(
      service: service,
      selectedAddons: state.selectedAddons,
      durationHours: state.durationHours,
    );
    state = state.copyWith(pricing: pricing);
  }

  Future<void> savePackage(String name) async {
    final service = state.service;
    final pricing = state.pricing;
    if (service == null || pricing == null) return;

    final pkg = SavedPackage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      serviceId: service.id,
      serviceName: service.name,
      addonIds: state.selectedAddonIds.toList(),
      durationHours: state.durationHours,
      pricing: pricing,
      savedAt: DateTime.now(),
    );
    await CacheService.savePackage(pkg);
  }

  void reset() {
    state = const PackageBuilderState();
  }
}

final packageBuilderProvider =
    StateNotifierProvider.autoDispose<
      PackageBuilderNotifier,
      PackageBuilderState
    >((ref) => PackageBuilderNotifier());

// ─── Bookings provider ────────────────────────────────────────────────────────

class BookingsState {
  final bool isLoading;
  final String? error;
  final bool submitted;

  const BookingsState({
    this.isLoading = false,
    this.error,
    this.submitted = false,
  });
}

class BookingsNotifier extends StateNotifier<BookingsState> {
  final Ref _ref;
  BookingsNotifier(this._ref) : super(const BookingsState());

  Future<bool> submitBooking(Map<String, dynamic> data) async {
    state = const BookingsState(isLoading: true);
    try {
      final api = _ref.read(apiServiceProvider);
      await api.createBooking(data);
      state = const BookingsState(submitted: true);
      return true;
    } catch (e) {
      state = BookingsState(error: e.toString(), isLoading: false);
      return false;
    }
  }
}

final bookingSubmitProvider =
    StateNotifierProvider.autoDispose<BookingsNotifier, BookingsState>(
      (ref) => BookingsNotifier(ref),
    );

// ─── My bookings ──────────────────────────────────────────────────────────────

final myBookingsProvider = FutureProvider.autoDispose((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getMyBookings();
});

// ─── All bookings (admin) ─────────────────────────────────────────────────────

final allBookingsProvider = FutureProvider.autoDispose((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getAllBookings();
});

// ─── Saved packages ───────────────────────────────────────────────────────────

final savedPackagesProvider = Provider.autoDispose((ref) {
  return CacheService.getSavedPackages();
});

// ─── Analytics ────────────────────────────────────────────────────────────────

final analyticsProvider = FutureProvider.autoDispose((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getAnalytics();
});
