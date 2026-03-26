import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../models/service_model.dart';
import '../models/addon_model.dart';
import '../models/booking_model.dart';
import '../models/price_calculation_model.dart';
import '../models/user_model.dart';

class ApiService {
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConfig.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Pass through — we handle errors in each method
          handler.next(error);
        },
      ),
    );
  }

  /// Extract a human-readable message from a Dio error
  String _parseError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'] as String;
      }
      if (data is String && data.isNotEmpty) return data;
      return 'Server error (${e.response!.statusCode})';
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your network.';
      case DioExceptionType.connectionError:
        return 'Could not connect to server. Is it running?';
      default:
        return e.message ?? 'Unknown error';
    }
  }

  // ─── AUTH ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    try {
      final res = await _dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final res = await _dio.get('/auth/profile');
      return UserModel.fromJson(res.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // ─── SERVICES ──────────────────────────────────────────────────────────────

  Future<List<ServiceModel>> getServices({String? category}) async {
    try {
      final res = await _dio.get(
        '/services',
        queryParameters: {if (category != null) 'category': category},
      );
      final list = res.data['services'] as List<dynamic>;
      return list
          .map((s) => ServiceModel.fromJson(s as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<ServiceModel> getService(String id) async {
    try {
      final res = await _dio.get('/services/$id');
      return ServiceModel.fromJson(res.data['service'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<ServiceModel> createService(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('/services', data: data);
      return ServiceModel.fromJson(res.data['service'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<ServiceModel> updateService(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final res = await _dio.put('/services/$id', data: data);
      return ServiceModel.fromJson(res.data['service'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<void> deleteService(String id) async {
    try {
      await _dio.delete('/services/$id');
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // ─── ADD-ONS ───────────────────────────────────────────────────────────────

  Future<List<AddonModel>> getAddons(String serviceId) async {
    try {
      final res = await _dio.get(
        '/addons',
        queryParameters: {'serviceId': serviceId},
      );
      final list = res.data['addons'] as List<dynamic>;
      return list
          .map((a) => AddonModel.fromJson(a as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<AddonModel> createAddon(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('/addons', data: data);
      return AddonModel.fromJson(res.data['addon'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<void> deleteAddon(String id) async {
    try {
      await _dio.delete('/addons/$id');
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // ─── PRICE CALCULATION ────────────────────────────────────────────────────

  Future<PriceCalculation> calculatePrice({
    required String serviceId,
    required int durationHours,
    required List<String> addonIds,
  }) async {
    try {
      final res = await _dio.post(
        '/calculate-price',
        data: {
          'serviceId': serviceId,
          'durationHours': durationHours,
          'addonIds': addonIds,
        },
      );
      return PriceCalculation.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // ─── BOOKINGS ──────────────────────────────────────────────────────────────

  Future<BookingModel> createBooking(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('/bookings', data: data);
      return BookingModel.fromJson(
        res.data['booking'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<List<BookingModel>> getMyBookings() async {
    try {
      final res = await _dio.get('/bookings/my');
      final list = res.data['bookings'] as List<dynamic>;
      return list
          .map((b) => BookingModel.fromJson(b as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<List<BookingModel>> getAllBookings() async {
    try {
      final res = await _dio.get('/bookings');
      final list = res.data['bookings'] as List<dynamic>;
      return list
          .map((b) => BookingModel.fromJson(b as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<BookingModel> updateBookingStatus(String id, String status) async {
    try {
      final res = await _dio.patch(
        '/bookings/$id/status',
        data: {'status': status},
      );
      return BookingModel.fromJson(
        res.data['booking'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // ─── ANALYTICS ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final res = await _dio.get('/analytics');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }
}
