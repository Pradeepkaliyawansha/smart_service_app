import '../config/app_config.dart';
import '../models/addon_model.dart';
import '../models/price_calculation_model.dart';
import '../models/service_model.dart';

class PriceCalculatorService {
  /// Local (offline) price calculation — mirrors backend logic
  static PriceCalculation calculate({
    required ServiceModel service,
    required List<AddonModel> selectedAddons,
    required int durationHours,
  }) {
    final basePrice = service.basePrice;
    final durationCost = service.pricePerHour * durationHours;
    final addonsCost = selectedAddons.fold<double>(
      0,
      (sum, a) => sum + a.price,
    );
    final subtotal = basePrice + durationCost + addonsCost;

    // Smart discount logic
    double discountRate = 0;
    String? discountReason;

    final itemCount = selectedAddons.length;
    if (itemCount >= 5) {
      discountRate = AppConfig.bulkDiscountRate;
      discountReason =
          '${(AppConfig.bulkDiscountRate * 100).toInt()}% off — Premium bundle!';
    } else if (itemCount >= AppConfig.discountThreshold) {
      discountRate = AppConfig.discountRate;
      discountReason =
          '${(AppConfig.discountRate * 100).toInt()}% off — Multi-item deal!';
    }

    final discountAmount = subtotal * discountRate;
    final totalPrice = subtotal - discountAmount;

    // Recommendation logic
    String? recommendation;
    bool isBestValue = false;
    bool isMostPopular = false;

    if (itemCount >= 3 && itemCount <= 5 && durationHours >= 3) {
      isBestValue = true;
      recommendation = '🏆 Best Value Combo — Great balance of features!';
    }

    final popularAddons = selectedAddons.where((a) => a.isPopular).length;
    if (popularAddons >= 2) {
      isMostPopular = true;
      recommendation = recommendation ?? '🔥 Most Chosen Package by customers!';
    }

    if (discountRate > 0 && recommendation == null) {
      recommendation =
          '💡 You qualify for a ${(discountRate * 100).toInt()}% bundle discount!';
    }

    return PriceCalculation(
      basePrice: basePrice,
      durationCost: durationCost,
      addonsCost: addonsCost,
      subtotal: subtotal,
      discountAmount: discountAmount,
      discountRate: discountRate,
      totalPrice: totalPrice,
      discountReason: discountReason,
      recommendation: recommendation,
      isBestValue: isBestValue,
      isMostPopular: isMostPopular,
    );
  }
}
