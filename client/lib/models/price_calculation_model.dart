class PriceCalculation {
  final double basePrice;
  final double durationCost;
  final double addonsCost;
  final double subtotal;
  final double discountAmount;
  final double discountRate;
  final double totalPrice;
  final String? discountReason;
  final String? recommendation;
  final bool isBestValue;
  final bool isMostPopular;

  const PriceCalculation({
    required this.basePrice,
    required this.durationCost,
    required this.addonsCost,
    required this.subtotal,
    required this.discountAmount,
    required this.discountRate,
    required this.totalPrice,
    this.discountReason,
    this.recommendation,
    this.isBestValue = false,
    this.isMostPopular = false,
  });

  factory PriceCalculation.fromJson(Map<String, dynamic> json) {
    return PriceCalculation(
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      durationCost: (json['durationCost'] ?? 0).toDouble(),
      addonsCost: (json['addonsCost'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      discountRate: (json['discountRate'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      discountReason: json['discountReason'],
      recommendation: json['recommendation'],
      isBestValue: json['isBestValue'] ?? false,
      isMostPopular: json['isMostPopular'] ?? false,
    );
  }

  bool get hasDiscount => discountAmount > 0;
}

class SavedPackage {
  final String id;
  final String name;
  final String serviceId;
  final String serviceName;
  final List<String> addonIds;
  final int durationHours;
  final PriceCalculation pricing;
  final DateTime savedAt;

  SavedPackage({
    required this.id,
    required this.name,
    required this.serviceId,
    required this.serviceName,
    required this.addonIds,
    required this.durationHours,
    required this.pricing,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'serviceId': serviceId,
    'serviceName': serviceName,
    'addonIds': addonIds,
    'durationHours': durationHours,
    'pricing': {
      'basePrice': pricing.basePrice,
      'durationCost': pricing.durationCost,
      'addonsCost': pricing.addonsCost,
      'subtotal': pricing.subtotal,
      'discountAmount': pricing.discountAmount,
      'discountRate': pricing.discountRate,
      'totalPrice': pricing.totalPrice,
    },
    'savedAt': savedAt.toIso8601String(),
  };

  factory SavedPackage.fromJson(Map<String, dynamic> json) {
    return SavedPackage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      serviceId: json['serviceId'] ?? '',
      serviceName: json['serviceName'] ?? '',
      addonIds: List<String>.from(json['addonIds'] ?? []),
      durationHours: json['durationHours'] ?? 1,
      pricing: PriceCalculation.fromJson(json['pricing'] ?? {}),
      savedAt: json['savedAt'] != null
          ? DateTime.parse(json['savedAt'])
          : DateTime.now(),
    );
  }
}
