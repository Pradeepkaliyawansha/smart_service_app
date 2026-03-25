import 'package:hive/hive.dart';
import 'addon_model.dart';

part 'service_model.g.dart';

@HiveType(typeId: 1)
class ServiceModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double basePrice;

  @HiveField(4)
  final double pricePerHour;

  @HiveField(5)
  final String category; // 'photography' | 'aquaculture' | 'custom' | etc.

  @HiveField(6)
  final String? imageUrl;

  @HiveField(7)
  final List<String> tags;

  @HiveField(8)
  final int minHours;

  @HiveField(9)
  final int maxHours;

  @HiveField(10)
  final bool isActive;

  @HiveField(11)
  final int bookingCount; // for "most popular" badge

  @HiveField(12)
  final List<AddonModel> addons;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.pricePerHour,
    required this.category,
    this.imageUrl,
    required this.tags,
    required this.minHours,
    required this.maxHours,
    required this.isActive,
    required this.bookingCount,
    required this.addons,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      pricePerHour: (json['pricePerHour'] ?? 0).toDouble(),
      category: json['category'] ?? 'custom',
      imageUrl: json['imageUrl'],
      tags: List<String>.from(json['tags'] ?? []),
      minHours: json['minHours'] ?? 1,
      maxHours: json['maxHours'] ?? 24,
      isActive: json['isActive'] ?? true,
      bookingCount: json['bookingCount'] ?? 0,
      addons: (json['addons'] as List<dynamic>? ?? [])
          .map((a) => AddonModel.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'description': description,
    'basePrice': basePrice,
    'pricePerHour': pricePerHour,
    'category': category,
    'imageUrl': imageUrl,
    'tags': tags,
    'minHours': minHours,
    'maxHours': maxHours,
    'isActive': isActive,
    'bookingCount': bookingCount,
    'addons': addons.map((a) => a.toJson()).toList(),
  };

  String get categoryIcon {
    switch (category.toLowerCase()) {
      case 'photography':
        return '📷';
      case 'aquaculture':
        return '🐟';
      case 'videography':
        return '🎥';
      case 'event':
        return '🎉';
      case 'construction':
        return '🏗️';
      default:
        return '⚙️';
    }
  }
}
