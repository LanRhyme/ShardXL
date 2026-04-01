import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../frb/shardxl_ffi_bindings.dart';

enum AuthMethod { microsoft, elyBy, offline }

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

    if (username != null && uuid != null) {
      AuthMethod? method;
      if (methodStr == 'microsoft') {
        method = AuthMethod.microsoft;
      } else if (methodStr == 'elyBy') {
        method = AuthMethod.elyBy;
      } else if (methodStr == 'offline') {
        method = AuthMethod.offline;
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

  Future<void> authenticateOffline(String username) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = authenticateOfflineFfi(username);
      
      if (!result.success) {
        throw Exception(result.error ?? 'Authentication failed');
      }
      
      final profile = result.profile;
      if (profile == null) {
        throw Exception('No profile returned');
      }

      await _saveAuth(profile.username, profile.uuid, profile.accessToken, AuthMethod.offline);
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        username: profile.username,
        uuid: profile.uuid,
        accessToken: profile.accessToken,
        authMethod: AuthMethod.offline,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> authenticateWithMicrosoft(String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Implement Microsoft authentication via ShardXL-Lib
      // This requires the full ShardXL-Lib FFI setup with Microsoft OAuth
      throw UnimplementedError('Microsoft authentication not yet implemented');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> authenticateWithElyBy(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Implement Ely.by authentication via ShardXL-Lib
      throw UnimplementedError('Ely.by authentication not yet implemented');
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
      // TODO: Implement Ely.by 2FA via ShardXL-Lib
      throw UnimplementedError('Ely.by 2FA not yet implemented');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _saveAuth(String username, String uuid, String? accessToken, AuthMethod method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyUuid, uuid);
    if (accessToken != null) {
      await prefs.setString(_keyAccessToken, accessToken);
    }
    await prefs.setString(
      _keyAuthMethod,
      method == AuthMethod.microsoft ? 'microsoft' 
          : method == AuthMethod.elyBy ? 'elyBy' 
          : 'offline',
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
