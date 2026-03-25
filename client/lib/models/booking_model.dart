import 'package:hive/hive.dart';

part 'booking_model.g.dart';

@HiveType(typeId: 3)
class BookingModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String serviceId;

  @HiveField(3)
  final String serviceName;

  @HiveField(4)
  final List<String> selectedAddonIds;

  @HiveField(5)
  final List<String> selectedAddonNames;

  @HiveField(6)
  final int durationHours;

  @HiveField(7)
  final double basePrice;

  @HiveField(8)
  final double addonsTotal;

  @HiveField(9)
  final double discountAmount;

  @HiveField(10)
  final double totalPrice;

  @HiveField(11)
  final String status; // 'pending' | 'confirmed' | 'cancelled' | 'completed'

  @HiveField(12)
  final DateTime bookingDate;

  @HiveField(13)
  final DateTime? eventDate;

  @HiveField(14)
  final String? notes;

  @HiveField(15)
  final String packageName; // user-given name

  BookingModel({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    required this.selectedAddonIds,
    required this.selectedAddonNames,
    required this.durationHours,
    required this.basePrice,
    required this.addonsTotal,
    required this.discountAmount,
    required this.totalPrice,
    required this.status,
    required this.bookingDate,
    this.eventDate,
    this.notes,
    required this.packageName,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      serviceId: json['serviceId'] ?? '',
      serviceName: json['serviceName'] ?? '',
      selectedAddonIds: List<String>.from(json['selectedAddonIds'] ?? []),
      selectedAddonNames: List<String>.from(json['selectedAddonNames'] ?? []),
      durationHours: json['durationHours'] ?? 1,
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      addonsTotal: (json['addonsTotal'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      bookingDate: json['bookingDate'] != null
          ? DateTime.parse(json['bookingDate'])
          : DateTime.now(),
      eventDate: json['eventDate'] != null
          ? DateTime.parse(json['eventDate'])
          : null,
      notes: json['notes'],
      packageName: json['packageName'] ?? 'My Package',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'userId': userId,
    'serviceId': serviceId,
    'serviceName': serviceName,
    'selectedAddonIds': selectedAddonIds,
    'selectedAddonNames': selectedAddonNames,
    'durationHours': durationHours,
    'basePrice': basePrice,
    'addonsTotal': addonsTotal,
    'discountAmount': discountAmount,
    'totalPrice': totalPrice,
    'status': status,
    'bookingDate': bookingDate.toIso8601String(),
    'eventDate': eventDate?.toIso8601String(),
    'notes': notes,
    'packageName': packageName,
  };

  Color get statusColor {
    switch (status) {
      case 'confirmed':
        return const Color(0xFF4CAF82);
      case 'cancelled':
        return const Color(0xFFFF5C6A);
      case 'completed':
        return const Color(0xFF4A9EFF);
      default:
        return const Color(0xFFFFC107);
    }
  }

  bool get canCancel => status == 'pending' || status == 'confirmed';
}

// ignore: avoid_classes_with_only_static_members
class Color {
  final int value;
  const Color(this.value);
}
