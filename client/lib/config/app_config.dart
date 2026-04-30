/// Application-wide configuration.
///
/// Base URL is resolved at compile-time via --dart-define so the same binary
/// can be pointed at different environments without code changes:
///
///   # Android emulator (default)
///   flutter run
///
///   # iOS simulator
///   flutter run --dart-define=BASE_URL=http://localhost:5000/api
///
///   # Physical device (replace with your machine's LAN IP)
///   flutter run --dart-define=BASE_URL=http://192.168.1.42:5000/api
///
///   # Production
///   flutter run --dart-define=BASE_URL=https://your-render-url.onrender.com/api
///
/// For release builds pass the same flag to `flutter build`:
///   flutter build apk --dart-define=BASE_URL=https://your-render-url.onrender.com/api
class AppConfig {
  // FIX: Was hardcoded to Android emulator address with no way to override
  // at runtime. Now reads from --dart-define so the same binary works across
  // emulator, simulator, physical device, and production without code edits.
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api', // Android emulator default
  );

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
  static const int discountThreshold = 3;
  static const double discountRate = 0.10;
  static const double bulkDiscountRate = 0.15;

  // Currency
  static const String currency = 'LKR';
  static const String currencySymbol = 'Rs.';
}
