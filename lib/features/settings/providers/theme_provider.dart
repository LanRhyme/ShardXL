// ShardXL 主题状态管理（Riverpod Notifier）
// lib/features/settings/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/shard_theme.dart';

// ========================
// 主题状态类
// ========================

/// 主题状态，包含当前主题配置和加载状态
class ThemeState {
  final ShardTheme theme;
  final bool isLoading;

  const ThemeState({
    required this.theme,
    this.isLoading = false,
  });

  ThemeState copyWith({
    ShardTheme? theme,
    bool? isLoading,
  }) {
    return ThemeState(
      theme: theme ?? this.theme,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ========================
// 主题 Notifier
// ========================

/// 主题状态管理器
/// 负责加载、保存、更新主题配置
class ShardThemeNotifier extends Notifier<ThemeState> {
  static const String _storageKey = 'shard_theme_config';

  @override
  ThemeState build() {
    // 初始状态为默认主题
    return const ThemeState(theme: ShardTheme());
  }

  /// 从本地存储加载主题配置
  Future<void> loadTheme() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final themeJson = prefs.getString(_storageKey);

      if (themeJson != null) {
        final theme = ShardTheme.fromJson(themeJson);
        state = ThemeState(theme: theme, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      // 加载失败时使用默认主题
      debugPrint('Failed to load theme: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// 保存主题配置到本地存储
  Future<void> _saveTheme(ShardTheme theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, theme.toJson());
    } catch (e) {
      debugPrint('Failed to save theme: $e');
    }
  }

  // ========================
  // 单独更新方法
  // ========================

  /// 更新深色模式
  Future<void> updateIsDark(bool isDark) async {
    final newTheme = state.theme.copyWith(isDark: isDark);
    state = state.copyWith(theme: newTheme);
    await _saveTheme(newTheme);
  }

  /// 更新主色
  Future<void> updatePrimaryColor(Color color) async {
    final newTheme = state.theme.copyWith(primaryColor: color);
    state = state.copyWith(theme: newTheme);
    await _saveTheme(newTheme);
  }

  /// 更新卡片不透明度
  Future<void> updateCardOpacity(double opacity) async {
    final clampedOpacity = opacity.clamp(0.15, 0.95);
    final newTheme = state.theme.copyWith(cardOpacity: clampedOpacity);
    state = state.copyWith(theme: newTheme);
    await _saveTheme(newTheme);
  }

  /// 更新 UI 缩放
  Future<void> updateUiScale(double scale) async {
    final clampedScale = scale.clamp(0.85, 1.5);
    final newTheme = state.theme.copyWith(uiScale: clampedScale);
    state = state.copyWith(theme: newTheme);
    await _saveTheme(newTheme);
  }

  /// 更新动画速率
  Future<void> updateAnimationSpeed(double speed) async {
    final clampedSpeed = speed.clamp(0.5, 2.0);
    final newTheme = state.theme.copyWith(animationSpeed: clampedSpeed);
    state = state.copyWith(theme: newTheme);
    await _saveTheme(newTheme);
  }

  /// 更新圆角大小
  Future<void> updateBorderRadius(double radius) async {
    final clampedRadius = radius.clamp(4.0, 20.0);
    final newTheme = state.theme.copyWith(borderRadius: clampedRadius);
    state = state.copyWith(theme: newTheme);
    await _saveTheme(newTheme);
  }

  /// 更新背景类型
  Future<void> updateBackgroundType(String type) async {
    const validTypes = ['solid', 'gradient', 'image', 'dynamic', 'mica'];
    if (!validTypes.contains(type)) return;

    final newTheme = state.theme.copyWith(backgroundType: type);
    state = state.copyWith(theme: newTheme);
    await _saveTheme(newTheme);
  }

  /// 更新背景图片
  Future<void> updateBackgroundImage(String? imagePath) async {
    final newTheme = state.theme.copyWith(backgroundImagePath: imagePath);
    state = state.copyWith(theme: newTheme);
    await _saveTheme(newTheme);
  }

  /// 更新图片背景模糊程度
  Future<void> updateGlassBlurSigma(double sigma) async {
    final clampedSigma = sigma.clamp(0.0, 50.0);
    final newTheme = state.theme.copyWith(glassBlurSigma: clampedSigma);
    state = state.copyWith(theme: newTheme);
    await _saveTheme(newTheme);
  }

  /// 更新图片背景遮罩不透明度
  Future<void> updateMaskOpacity(double opacity) async {
    final clampedOpacity = opacity.clamp(0.0, 1.0);
    final newTheme = state.theme.copyWith(maskOpacity: clampedOpacity);
    state = state.copyWith(theme: newTheme);
    await _saveTheme(newTheme);
  }

  /// 重置为默认主题
  Future<void> resetToDefault() async {
    const defaultTheme = ShardTheme();
    state = const ThemeState(theme: defaultTheme);
    await _saveTheme(defaultTheme);
  }

  /// 批量更新主题
  Future<void> updateTheme(ShardTheme theme) async {
    state = state.copyWith(theme: theme);
    await _saveTheme(theme);
  }
}

// ========================
// Riverpod Providers
// ========================

/// 主题 NotifierProvider
final shardThemeProvider =
    NotifierProvider<ShardThemeNotifier, ThemeState>(ShardThemeNotifier.new);

/// 便捷访问：当前 ThemeData
final currentThemeDataProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(shardThemeProvider);
  return themeState.theme.toThemeData();
});

/// 便捷访问：当前 ShardTheme
final currentShardThemeProvider = Provider<ShardTheme>((ref) {
  return ref.watch(shardThemeProvider).theme;
});

/// 便捷访问：主题扩展
final shardThemeExtensionProvider = Provider<ShardThemeExtension>((ref) {
  final themeData = ref.watch(currentThemeDataProvider);
  return themeData.extension<ShardThemeExtension>() ??
      const ShardThemeExtension(
        glassBlurSigma: 12.0,
        glassBorderWidth: 1.0,
        glowColor: Color(0xFF7C4DFF),
        cardBorderRadius: 10.0,
        buttonBorderRadius: 10.0,
        inputBorderRadius: 10.0,
        animationDurationFactor: 1.0,
      );
});