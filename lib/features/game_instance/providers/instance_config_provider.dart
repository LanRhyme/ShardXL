import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 单个游戏实例的配置
class InstanceConfig {
  final String? javaPath;
  final int? memoryMB;
  final int? windowWidth;
  final int? windowHeight;
  final bool? fullscreen;
  final List<String>? jvmArguments;
  final List<String>? gameArguments;
  final bool versionIsolation;
  final bool integrityCheck;

  const InstanceConfig({
    this.javaPath,
    this.memoryMB,
    this.windowWidth,
    this.windowHeight,
    this.fullscreen,
    this.jvmArguments,
    this.gameArguments,
    this.versionIsolation = false,
    this.integrityCheck = true,
  });

  InstanceConfig copyWith({
    String? javaPath,
    int? memoryMB,
    int? windowWidth,
    int? windowHeight,
    bool? fullscreen,
    List<String>? jvmArguments,
    List<String>? gameArguments,
    bool? versionIsolation,
    bool? integrityCheck,
  }) {
    return InstanceConfig(
      javaPath: javaPath ?? this.javaPath,
      memoryMB: memoryMB ?? this.memoryMB,
      windowWidth: windowWidth ?? this.windowWidth,
      windowHeight: windowHeight ?? this.windowHeight,
      fullscreen: fullscreen ?? this.fullscreen,
      jvmArguments: jvmArguments ?? this.jvmArguments,
      gameArguments: gameArguments ?? this.gameArguments,
      versionIsolation: versionIsolation ?? this.versionIsolation,
      integrityCheck: integrityCheck ?? this.integrityCheck,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'javaPath': javaPath,
      'memoryMB': memoryMB,
      'windowWidth': windowWidth,
      'windowHeight': windowHeight,
      'fullscreen': fullscreen,
      'jvmArguments': jvmArguments,
      'gameArguments': gameArguments,
      'versionIsolation': versionIsolation,
      'integrityCheck': integrityCheck,
    };
  }

  factory InstanceConfig.fromJson(Map<String, dynamic> json) {
    return InstanceConfig(
      javaPath: json['javaPath'] as String?,
      memoryMB: json['memoryMB'] as int?,
      windowWidth: json['windowWidth'] as int?,
      windowHeight: json['windowHeight'] as int?,
      fullscreen: json['fullscreen'] as bool?,
      jvmArguments: (json['jvmArguments'] as List<dynamic>?)?.cast<String>(),
      gameArguments: (json['gameArguments'] as List<dynamic>?)?.cast<String>(),
      versionIsolation: json['versionIsolation'] as bool? ?? false,
      integrityCheck: json['integrityCheck'] as bool? ?? true,
    );
  }
}

class InstanceConfigNotifier extends StateNotifier<InstanceConfig> {
  String? _currentVersion;

  InstanceConfigNotifier() : super(const InstanceConfig());

  static const _keyPrefix = 'instance_config_';

  Future<void> loadConfig(String version) async {
    _currentVersion = version;
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$version';
    final jsonStr = prefs.getString(key);

    if (jsonStr != null) {
      try {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        state = InstanceConfig.fromJson(json);
      } catch (e) {
        state = const InstanceConfig();
      }
    } else {
      state = const InstanceConfig();
    }
  }

  Future<void> _saveConfig() async {
    if (_currentVersion == null) return;
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$_currentVersion';
    await prefs.setString(key, jsonEncode(state.toJson()));
  }

  Future<void> setJavaPath(String? path) async {
    state = state.copyWith(javaPath: path?.isEmpty ?? true ? null : path);
    await _saveConfig();
  }

  Future<void> setMemoryMB(int memory) async {
    state = state.copyWith(memoryMB: memory);
    await _saveConfig();
  }

  Future<void> setWindowSize({int? width, int? height}) async {
    state = state.copyWith(
      windowWidth: width,
      windowHeight: height,
    );
    await _saveConfig();
  }

  Future<void> setFullscreen(bool fullscreen) async {
    state = state.copyWith(fullscreen: fullscreen);
    await _saveConfig();
  }

  Future<void> setJvmArguments(List<String> args) async {
    state = state.copyWith(jvmArguments: args.isEmpty ? null : args);
    await _saveConfig();
  }

  Future<void> setGameArguments(List<String> args) async {
    state = state.copyWith(gameArguments: args.isEmpty ? null : args);
    await _saveConfig();
  }

  Future<void> setVersionIsolation(bool enabled) async {
    state = state.copyWith(versionIsolation: enabled);
    await _saveConfig();
  }

  Future<void> setIntegrityCheck(bool enabled) async {
    state = state.copyWith(integrityCheck: enabled);
    await _saveConfig();
  }

  Future<void> resetToDefault() async {
    state = const InstanceConfig();
    await _saveConfig();
  }
}

final instanceConfigProvider = StateNotifierProvider<InstanceConfigNotifier, InstanceConfig>((ref) {
  return InstanceConfigNotifier();
});
