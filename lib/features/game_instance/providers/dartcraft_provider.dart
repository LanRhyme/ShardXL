import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../../frb/shardxl_ffi_bindings.dart';

class MinecraftVersion {
  final String id;
  final String versionType;
  final DateTime releaseTime;

  MinecraftVersion({
    required this.id,
    required this.versionType,
    required this.releaseTime,
  });

  factory MinecraftVersion.fromJson(Map<String, dynamic> json) {
    return MinecraftVersion(
      id: json['id'] as String,
      versionType: json['versionType'] as String,
      releaseTime: DateTime.parse(json['releaseTime'] as String),
    );
  }
}

class GameSettings {
  final String javaPath;
  final int memoryMB;
  final String gameDirectory;
  final int windowWidth;
  final int windowHeight;
  final bool fullscreen;
  final List<String> jvmArguments;
  final List<String> gameArguments;

  const GameSettings({
    this.javaPath = '',
    this.memoryMB = 4096,
    this.gameDirectory = '',
    this.windowWidth = 1920,
    this.windowHeight = 1080,
    this.fullscreen = false,
    this.jvmArguments = const [],
    this.gameArguments = const [],
  });

  GameSettings copyWith({
    String? javaPath,
    int? memoryMB,
    String? gameDirectory,
    int? windowWidth,
    int? windowHeight,
    bool? fullscreen,
    List<String>? jvmArguments,
    List<String>? gameArguments,
  }) {
    return GameSettings(
      javaPath: javaPath ?? this.javaPath,
      memoryMB: memoryMB ?? this.memoryMB,
      gameDirectory: gameDirectory ?? this.gameDirectory,
      windowWidth: windowWidth ?? this.windowWidth,
      windowHeight: windowHeight ?? this.windowHeight,
      fullscreen: fullscreen ?? this.fullscreen,
      jvmArguments: jvmArguments ?? this.jvmArguments,
      gameArguments: gameArguments ?? this.gameArguments,
    );
  }

  String get defaultJvmArg => '-Xmx${memoryMB}M';
  String get minJvmArg => '-Xms${(memoryMB ~/ 2)}M';
}

class GameSettingsNotifier extends StateNotifier<GameSettings> {
  GameSettingsNotifier() : super(const GameSettings());

  static const _keyJavaPath = 'game_java_path';
  static const _keyMemoryMB = 'game_memory_mb';
  static const _keyGameDirectory = 'game_directory';
  static const _keyWindowWidth = 'game_window_width';
  static const _keyWindowHeight = 'game_window_height';
  static const _keyFullscreen = 'game_fullscreen';
  static const _keyJvmArgs = 'game_jvm_args';
  static const _keyGameArgs = 'game_game_args';

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final javaPath = prefs.getString(_keyJavaPath) ?? '';
    final memoryMB = prefs.getInt(_keyMemoryMB) ?? 4096;
    final gameDirectory = prefs.getString(_keyGameDirectory) ?? _getDefaultGameDir();
    final windowWidth = prefs.getInt(_keyWindowWidth) ?? 1920;
    final windowHeight = prefs.getInt(_keyWindowHeight) ?? 1080;
    final fullscreen = prefs.getBool(_keyFullscreen) ?? false;
    final jvmArgs = prefs.getStringList(_keyJvmArgs) ?? [];
    final gameArgs = prefs.getStringList(_keyGameArgs) ?? [];

    state = GameSettings(
      javaPath: javaPath,
      memoryMB: memoryMB,
      gameDirectory: gameDirectory,
      windowWidth: windowWidth,
      windowHeight: windowHeight,
      fullscreen: fullscreen,
      jvmArguments: jvmArgs,
      gameArguments: gameArgs,
    );
  }

  String _getDefaultGameDir() {
    try {
      return getDefaultGameDirectory();
    } catch (e) {
      if (Platform.isWindows) {
        return '${Platform.environment['APPDATA'] ?? ''}/.minecraft';
      } else if (Platform.isMacOS) {
        return '${Platform.environment['HOME'] ?? ''}/Library/Application Support/minecraft';
      } else {
        return '${Platform.environment['HOME'] ?? ''}/.minecraft';
      }
    }
  }

  Future<void> setJavaPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyJavaPath, path);
    state = state.copyWith(javaPath: path);
  }

  Future<void> setMemoryMB(int mb) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMemoryMB, mb);
    state = state.copyWith(memoryMB: mb);
  }

  Future<void> setGameDirectory(String dir) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGameDirectory, dir);
    state = state.copyWith(gameDirectory: dir);
  }

  Future<void> setWindowSize(int width, int height) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyWindowWidth, width);
    await prefs.setInt(_keyWindowHeight, height);
    state = state.copyWith(windowWidth: width, windowHeight: height);
  }

  Future<void> setFullscreen(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFullscreen, value);
    state = state.copyWith(fullscreen: value);
  }

  Future<void> setJvmArguments(List<String> args) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyJvmArgs, args);
    state = state.copyWith(jvmArguments: args);
  }

  Future<void> setGameArguments(List<String> args) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyGameArgs, args);
    state = state.copyWith(gameArguments: args);
  }
}

final gameSettingsProvider =
    StateNotifierProvider<GameSettingsNotifier, GameSettings>((ref) {
  return GameSettingsNotifier();
});

final availableVersionsProvider = FutureProvider<List<MinecraftVersion>>((ref) async {
  try {
    final response = await http.get(
      Uri.parse('https://piston-meta.mojang.com/mc/game/version_manifest_v2.json'),
    ).timeout(const Duration(seconds: 15));
    
    if (response.statusCode != 200) {
      return [];
    }
    
    final manifest = json.decode(response.body);
    final versionsJson = manifest['versions'] as List<dynamic>?;
    
    if (versionsJson == null) {
      return [];
    }
    
    return versionsJson
        .where((v) => v['type'] == 'release')
        .map((v) => MinecraftVersion(
              id: v['id'] as String,
              versionType: v['type'] as String,
              releaseTime: DateTime.tryParse(v['releaseTime'] as String? ?? '') ?? DateTime.now(),
            ))
        .toList();
  } on SocketException {
    return [];
  } on TimeoutException {
    return [];
  } catch (e) {
    return [];
  }
});

final releaseVersionsProvider = FutureProvider<List<MinecraftVersion>>((ref) async {
  final allVersions = await ref.watch(availableVersionsProvider.future);
  return allVersions.where((v) => v.versionType == 'release').toList();
});

final installedVersionsProvider = FutureProvider<List<String>>((ref) async {
  final settings = ref.watch(gameSettingsProvider);
  final dir = settings.gameDirectory;
  if (dir.isEmpty) return [];
  
  try {
    return await Future.microtask(() => getInstalledVersions(dir));
  } catch (e) {
    return [];
  }
});

class LauncherInstance {
  final String version;
  final String gameDirectory;
  final GameSettings settings;

  LauncherInstance({
    required this.version,
    required this.gameDirectory,
    required this.settings,
  });
}

class VersionInstallResult {
  final bool success;
  final String? error;

  VersionInstallResult({required this.success, this.error});
}

Future<VersionInstallResult> installMinecraftVersion(String versionId, String gameDirectory) async {
  try {
    final result = await Future.microtask(() => installVersion(versionId, gameDirectory));
    return VersionInstallResult(
      success: result.success,
      error: result.error,
    );
  } catch (e) {
    return VersionInstallResult(success: false, error: e.toString());
  }
}

String checkJavaVersion(String? javaPath) {
  try {
    return checkJava(javaPath);
  } catch (e) {
    return 'Error checking Java: $e';
  }
}
