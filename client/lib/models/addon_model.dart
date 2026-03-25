import 'package:hive/hive.dart';

part 'addon_model.g.dart';

@HiveType(typeId: 2)
class AddonModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String serviceId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final double price;

  @HiveField(5)
  final String icon; // emoji icon

  @HiveField(6)
  final bool isPopular;

  @HiveField(7)
  final int selectCount; // how many times selected

  AddonModel({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.isPopular,
    required this.selectCount,
  });

  factory AddonModel.fromJson(Map<String, dynamic> json) {
    return AddonModel(
      id: json['_id'] ?? json['id'] ?? '',
      serviceId: json['serviceId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      icon: json['icon'] ?? '✨',
      isPopular: json['isPopular'] ?? false,
      selectCount: json['selectCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'serviceId': serviceId,
    'name': name,
    'description': description,
    'price': price,
    'icon': icon,
    'isPopular': isPopular,
    'selectCount': selectCount,
  };
}
