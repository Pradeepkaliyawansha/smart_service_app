class AppConfig {
  // Change this to your backend URL
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:5000/api'; // iOS simulator
  // static const String baseUrl = 'https://your-render-url.onrender.com/api'; // Production

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  static const String appName = 'PackageBuilder';
  static const String version = '1.0.0';

  // Hive box names
  static const String servicesBox = 'services_box';
  static const String addOnsBox = 'addons_box';
  static const String userBox = 'user_box';
  static const String bookingsBox = 'bookings_box';

  // Discount rules
  static const int discountThreshold = 3; // items to trigger discount
  static const double discountRate = 0.10; // 10%
  static const double bulkDiscountRate = 0.15; // 15% for 5+ items

  // Currency
  static const String currency = 'LKR';
  static const String currencySymbol = 'Rs.';
}
