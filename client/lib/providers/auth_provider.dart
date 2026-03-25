import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;
  bool get isAdmin => user?.isAdmin ?? false;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api;
  final _storage = const FlutterSecureStorage();

  AuthNotifier(this._api) : super(const AuthState()) {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    state = state.copyWith(isLoading: true);
    try {
      final token = await _storage.read(key: 'token');
      if (token != null && !JwtDecoder.isExpired(token)) {
        final user = await _api.getProfile();
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      await _storage.delete(key: 'token');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.login(email, password);
      final token = data['token'] as String;
      await _storage.write(key: 'token', value: token);
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.register(
        name: name,
        email: email,
        password: password,
      );
      final token = data['token'] as String;
      await _storage.write(key: 'token', value: token);
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    state = const AuthState();
  }

  String _parseError(dynamic e) {
    if (e is Exception) {
      return e.toString().replaceAll('Exception: ', '');
    }
    return 'Something went wrong';
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(apiServiceProvider));
});
