import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/app_config.dart';
import '../models/service_model.dart';
import '../models/addon_model.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../models/price_calculation_model.dart';

class CacheService {
  static Box? _servicesBox;
  static Box? _generalBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register all type adapters BEFORE opening boxes
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ServiceModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(AddonModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(BookingModelAdapter());
    }

    _servicesBox = await Hive.openBox(AppConfig.servicesBox);
    _generalBox = await Hive.openBox('general');
  }

  // ─── SERVICES ──────────────────────────────────────────────────────────────

  static Future<void> cacheServices(List<ServiceModel> services) async {
    final box = _servicesBox;
    if (box == null) return;
    await box.put(
      'services',
      jsonEncode(services.map((s) => s.toJson()).toList()),
    );
    // FIX: store cached_at in the same box as the data
    await box.put('services_cached_at', DateTime.now().toIso8601String());
  }

  static List<ServiceModel>? getCachedServices() {
    final box = _servicesBox;
    if (box == null) return null;
    final raw = box.get('services');
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw as String) as List<dynamic>;
      return list
          .map((s) => ServiceModel.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// FIX: was checking wrong box (_generalBox instead of _servicesBox for services)
  static bool isCacheValid(
    String key, {
    Duration maxAge = const Duration(minutes: 30),
  }) {
    // For 'services' key, check _servicesBox; everything else checks _generalBox
    final box = key == 'services' ? _servicesBox : _generalBox;
    if (box == null) return false;
    final cachedAt = box.get('${key}_cached_at');
    if (cachedAt == null) return false;
    try {
      final age = DateTime.now().difference(DateTime.parse(cachedAt as String));
      return age < maxAge;
    } catch (_) {
      return false;
    }
  }

  // ─── SAVED PACKAGES ───────────────────────────────────────────────────────

  static Future<void> savePackage(SavedPackage pkg) async {
    final box = _generalBox;
    if (box == null) return;
    final rawStr = box.get('saved_packages') as String?;
    final List<dynamic> existing =
        rawStr != null ? jsonDecode(rawStr) as List<dynamic> : [];
    existing.insert(0, pkg.toJson());
    await box.put('saved_packages', jsonEncode(existing));
  }

  static List<SavedPackage> getSavedPackages() {
    final box = _generalBox;
    if (box == null) return [];
    final raw = box.get('saved_packages');
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw as String) as List<dynamic>;
      return list
          .map((p) => SavedPackage.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> deletePackage(String id) async {
    final box = _generalBox;
    if (box == null) return;
    final packages = getSavedPackages();
    packages.removeWhere((p) => p.id == id);
    await box.put(
      'saved_packages',
      jsonEncode(packages.map((p) => p.toJson()).toList()),
    );
  }

  // ─── GENERAL ──────────────────────────────────────────────────────────────

  static Future<void> clear() async {
    await _servicesBox?.clear();
    await _generalBox?.clear();
  }
}
