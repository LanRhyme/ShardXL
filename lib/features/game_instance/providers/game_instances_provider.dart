import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 游戏实例信息
class GameInstance {
  final String id;
  final String name;
  final String version;
  final String? iconPath;
  final DateTime createdAt;
  final DateTime lastPlayed;
  final int playCount;

  GameInstance({
    required this.id,
    required this.name,
    required this.version,
    this.iconPath,
    required this.createdAt,
    required this.lastPlayed,
    this.playCount = 0,
  });

  GameInstance copyWith({
    String? id,
    String? name,
    String? version,
    String? iconPath,
    DateTime? createdAt,
    DateTime? lastPlayed,
    int? playCount,
  }) {
    return GameInstance(
      id: id ?? this.id,
      name: name ?? this.name,
      version: version ?? this.version,
      iconPath: iconPath ?? this.iconPath,
      createdAt: createdAt ?? this.createdAt,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      playCount: playCount ?? this.playCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'version': version,
      'iconPath': iconPath,
      'createdAt': createdAt.toIso8601String(),
      'lastPlayed': lastPlayed.toIso8601String(),
      'playCount': playCount,
    };
  }

  factory GameInstance.fromJson(Map<String, dynamic> json) {
    return GameInstance(
      id: json['id'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      iconPath: json['iconPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastPlayed: DateTime.parse(json['lastPlayed'] as String),
      playCount: json['playCount'] as int? ?? 0,
    );
  }
}

class GameInstancesNotifier extends StateNotifier<List<GameInstance>> {
  GameInstancesNotifier() : super([]);

  static const _key = 'game_instances';

  Future<void> loadInstances() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);

    if (jsonStr != null) {
      try {
        final jsonList = jsonDecode(jsonStr) as List<dynamic>;
        state = jsonList
            .map((json) => GameInstance.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        state = [];
      }
    }
  }

  Future<void> _saveInstances() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(state.map((i) => i.toJson()).toList());
    await prefs.setString(_key, jsonStr);
  }

  Future<void> addInstance(GameInstance instance) async {
    state = [...state, instance];
    await _saveInstances();
  }

  Future<void> updateInstance(GameInstance instance) async {
    state = state.map((i) => i.id == instance.id ? instance : i).toList();
    await _saveInstances();
  }

  Future<void> removeInstance(String id) async {
    state = state.where((i) => i.id != id).toList();
    await _saveInstances();
  }

  Future<void> recordPlay(String id) async {
    state = state.map((i) {
      if (i.id == id) {
        return i.copyWith(
          lastPlayed: DateTime.now(),
          playCount: i.playCount + 1,
        );
      }
      return i;
    }).toList();
    await _saveInstances();
  }
}

final gameInstancesProvider = StateNotifierProvider<GameInstancesNotifier, List<GameInstance>>((ref) {
  return GameInstancesNotifier();
});
