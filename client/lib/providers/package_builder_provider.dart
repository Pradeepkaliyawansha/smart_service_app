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

final packageBuilderProvider = StateNotifierProvider.autoDispose<
    PackageBuilderNotifier,
    PackageBuilderState>((ref) => PackageBuilderNotifier());

// ─── Bookings submit provider ─────────────────────────────────────────────────

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
// FIX: Was non-autoDispose but never explicitly invalidated on refresh.
// Kept non-autoDispose (so the data survives tab switches) but the admin
// bookings screen now calls ref.invalidate(allBookingsProvider) on
// pull-to-refresh and after each status change, so data stays fresh.
final allBookingsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    return await api.getAllBookings();
  } catch (e) {
    throw Exception(
        'Failed to load bookings: ${e.toString().replaceAll('Exception: ', '')}');
  }
});

// ─── Saved packages ───────────────────────────────────────────────────────────
// FIX: SavedPackagesScreen was calling ref.invalidate(savedPackagesProvider)
// but savedPackagesProvider is a plain Provider (synchronous, autoDispose).
// ref.invalidate() on an autoDispose Provider disposes it immediately, then
// the next read rebuilds it — that works for FutureProvider but for a plain
// Provider it just silently does nothing visible. The fix: keep the provider
// non-autoDispose and use ref.invalidate() which forces a rebuild on next
// watch, OR (simpler) keep autoDispose and use ref.refresh() which
// immediately rebuilds and returns the new value.
//
// We keep autoDispose=true and the screen must use:
//   ref.refresh(savedPackagesProvider);   ← not ref.invalidate(...)
final savedPackagesProvider = Provider.autoDispose((ref) {
  return CacheService.getSavedPackages();
});

// ─── Analytics ────────────────────────────────────────────────────────────────
// FIX: analyticsProvider is non-autoDispose and was never invalidated. The
// admin analytics screen now calls ref.invalidate(analyticsProvider) when
// it needs fresh data (e.g., on pull-to-refresh). Using keepAlive (default
// for non-autoDispose) is intentional so expensive analytics don't re-fetch
// on every tab switch.
final analyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    return await api.getAnalytics();
  } catch (e) {
    throw Exception(
        'Failed to load analytics: ${e.toString().replaceAll('Exception: ', '')}');
  }
});
