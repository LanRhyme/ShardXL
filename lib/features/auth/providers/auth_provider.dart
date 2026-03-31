import 'package:dartcraft/dartcraft.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthMethod { microsoft, elyBy }

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final String? username;
  final String? uuid;
  final String? accessToken;
  final AuthMethod? authMethod;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.username,
    this.uuid,
    this.accessToken,
    this.authMethod,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    String? username,
    String? uuid,
    String? accessToken,
    AuthMethod? authMethod,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      username: username ?? this.username,
      uuid: uuid ?? this.uuid,
      accessToken: accessToken ?? this.accessToken,
      authMethod: authMethod ?? this.authMethod,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  static const _keyUsername = 'auth_username';
  static const _keyUuid = 'auth_uuid';
  static const _keyAccessToken = 'auth_access_token';
  static const _keyAuthMethod = 'auth_method';

  Future<void> loadSavedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_keyUsername);
    final uuid = prefs.getString(_keyUuid);
    final accessToken = prefs.getString(_keyAccessToken);
    final methodStr = prefs.getString(_keyAuthMethod);

    if (username != null && uuid != null && accessToken != null) {
      AuthMethod? method;
      if (methodStr == 'microsoft') {
        method = AuthMethod.microsoft;
      } else if (methodStr == 'elyBy') {
        method = AuthMethod.elyBy;
      }
      state = AuthState(
        isAuthenticated: true,
        username: username,
        uuid: uuid,
        accessToken: accessToken,
        authMethod: method,
      );
    }
  }

  Future<void> authenticateWithMicrosoft(String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await Dartcraft.authenticateWithMicrosoft(code);
      await _saveAuth(result, AuthMethod.microsoft);
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        username: result.username,
        uuid: result.uuid,
        accessToken: result.accessToken,
        authMethod: AuthMethod.microsoft,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> authenticateWithElyBy(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final launcher = Dartcraft('1.20.4', '', useElyBy: true);
      final result = await launcher.authenticateWithElyBy(username, password);
      await _saveAuth(result, AuthMethod.elyBy);
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        username: result.username,
        uuid: result.uuid,
        accessToken: result.accessToken,
        authMethod: AuthMethod.elyBy,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> authenticateWithElyByTwoFactor(
    String username,
    String password,
    String totpCode,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final launcher = Dartcraft('1.20.4', '', useElyBy: true);
      final result = await launcher.authenticateWithElyByTwoFactor(
        username,
        password,
        totpCode,
      );
      await _saveAuth(result, AuthMethod.elyBy);
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        username: result.username,
        uuid: result.uuid,
        accessToken: result.accessToken,
        authMethod: AuthMethod.elyBy,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _saveAuth(AuthenticationResult result, AuthMethod method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, result.username);
    await prefs.setString(_keyUuid, result.uuid);
    await prefs.setString(_keyAccessToken, result.accessToken);
    await prefs.setString(
      _keyAuthMethod,
      method == AuthMethod.microsoft ? 'microsoft' : 'elyBy',
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyUuid);
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyAuthMethod);
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
