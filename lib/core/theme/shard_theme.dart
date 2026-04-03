// ShardXL 主题数据模型
// lib/core/theme/shard_theme.dart
// 基于 shadcn-ui 设计语言

import 'dart:convert';
import 'package:flutter/material.dart';

/// ShardXL 主题配置类
/// 包含所有可自定义的主题参数，支持序列化和持久化
class ShardTheme {
  // ========================
  // 主题模式参数
  // ========================

  /// 是否为深色模式（默认 true）
  final bool isDark;

  /// 主色（用户自定义，用于生成完整 ColorScheme）
  final Color primaryColor;

  // ========================
  // 玻璃效果参数
  // ========================

  /// 卡片不透明度（范围 0.15 ~ 0.95，默认 0.65）
  final double cardOpacity;

  // ========================
  // UI 参数
  // ========================

  /// UI 整体缩放（范围 0.85 ~ 1.5，默认 1.0）
  final double uiScale;

  /// 动画速率（范围 0.5 ~ 2.0，默认 1.0）
  final double animationSpeed;

  // ========================
  // 圆角参数（shadcn-ui 风格）
  // ========================

  /// 基础圆角值（shadcn-ui 默认 0.625rem ≈ 10px）
  final double borderRadius;

  // ========================
  // 背景参数
  // ========================

  /// 背景类型：'solid' | 'gradient' | 'image' | 'dynamic'
  final String backgroundType;

  /// 背景图片路径（仅在 backgroundType 为 'image' 时使用）
  final String? backgroundImagePath;

  /// 图片背景模糊程度（仅在 backgroundType 为 'image' 时使用）
  final double glassBlurSigma;

  /// 图片背景遮罩不透明度（仅在 backgroundType 为 'image' 时使用）
  final double maskOpacity;

  const ShardTheme({
    this.isDark = true,
    this.primaryColor = const Color(0xFF4A90D9),
    this.cardOpacity = 0.65,
    this.uiScale = 1.0,
    this.animationSpeed = 1.0,
    this.borderRadius = 6.0,
    this.backgroundType = 'solid',
    this.backgroundImagePath,
    this.glassBlurSigma = 10.0,
    this.maskOpacity = 0.5,
  });

  // ========================
  // 复制方法
  // ========================

  ShardTheme copyWith({
    bool? isDark,
    Color? primaryColor,
    double? cardOpacity,
    double? uiScale,
    double? animationSpeed,
    double? borderRadius,
    String? backgroundType,
    String? backgroundImagePath,
    double? glassBlurSigma,
    double? maskOpacity,
  }) {
    return ShardTheme(
      isDark: isDark ?? this.isDark,
      primaryColor: primaryColor ?? this.primaryColor,
      cardOpacity: cardOpacity ?? this.cardOpacity,
      uiScale: uiScale ?? this.uiScale,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      borderRadius: borderRadius ?? this.borderRadius,
      backgroundType: backgroundType ?? this.backgroundType,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      glassBlurSigma: glassBlurSigma ?? this.glassBlurSigma,
      maskOpacity: maskOpacity ?? this.maskOpacity,
    );
  }

  // ========================
  // 序列化方法
  // ========================

  Map<String, dynamic> toMap() {
    return {
      'isDark': isDark,
      'primaryColor': primaryColor.toARGB32(),
      'cardOpacity': cardOpacity,
      'uiScale': uiScale,
      'animationSpeed': animationSpeed,
      'borderRadius': borderRadius,
      'backgroundType': backgroundType,
      'backgroundImagePath': backgroundImagePath,
      'glassBlurSigma': glassBlurSigma,
      'maskOpacity': maskOpacity,
    };
  }

  factory ShardTheme.fromMap(Map<String, dynamic> map) {
    return ShardTheme(
      isDark: map['isDark'] ?? true,
      primaryColor: Color(map['primaryColor'] ?? 0xFF4A90D9),
      cardOpacity: (map['cardOpacity'] ?? 0.65).toDouble(),
      uiScale: (map['uiScale'] ?? 1.0).toDouble(),
      animationSpeed: (map['animationSpeed'] ?? 1.0).toDouble(),
      borderRadius: (map['borderRadius'] ?? 10.0).toDouble(),
      backgroundType: map['backgroundType'] ?? 'gradient',
      backgroundImagePath: map['backgroundImagePath'] as String?,
      glassBlurSigma: (map['glassBlurSigma'] ?? 10.0).toDouble(),
      maskOpacity: (map['maskOpacity'] ?? 0.5).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ShardTheme.fromJson(String source) =>
      ShardTheme.fromMap(json.decode(source));

  // ========================
  // 生成 Material 3 ThemeData
  // ========================

  /// 构建完整的 ColorScheme，保留用户选择颜色的饱和度和明度
  ColorScheme _buildColorScheme(Color primary, bool isDark) {
    final hsl = HSLColor.fromColor(primary);
    final hue = hsl.hue;
    final sat = hsl.saturation;
    final light = hsl.lightness;

    // 生成 primaryContainer：比 primary 更亮/更淡
    final primaryContainer = HSLColor.fromAHSL(
      1.0,
      hue,
      sat * 0.7,
      isDark ? (light + 0.15).clamp(0.0, 0.4) : (light + 0.25).clamp(0.5, 0.85),
    ).toColor();

    // 生成 secondary：色相偏移 30 度
    final secondary = HSLColor.fromAHSL(
      1.0,
      (hue + 30) % 360,
      sat * 0.8,
      light,
    ).toColor();

    // 生成 secondaryContainer
    final secondaryContainer = HSLColor.fromAHSL(
      1.0,
      (hue + 30) % 360,
      sat * 0.5,
      isDark ? (light + 0.15).clamp(0.0, 0.4) : (light + 0.25).clamp(0.5, 0.85),
    ).toColor();

    // 生成 tertiary：色相偏移 60 度
    final tertiary = HSLColor.fromAHSL(
      1.0,
      (hue + 60) % 360,
      sat * 0.6,
      light,
    ).toColor();

    // 生成 error：保持红色系
    final error = HSLColor.fromAHSL(1.0, 0, sat * 0.8, isDark ? 0.5 : 0.45).toColor();
    final errorContainer = HSLColor.fromAHSL(1.0, 0, sat * 0.3, isDark ? 0.15 : 0.9).toColor();

    // Surface 颜色
    final surface = HSLColor.fromAHSL(1.0, hue, sat * 0.10, isDark ? 0.09 : 0.93).toColor();
    final surfaceContainerLowest = HSLColor.fromAHSL(1.0, hue, sat * 0.08, isDark ? 0.06 : 0.91).toColor();
    final surfaceContainer = HSLColor.fromAHSL(1.0, hue, sat * 0.10, isDark ? 0.10 : 0.94).toColor();
    final surfaceContainerHigh = HSLColor.fromAHSL(1.0, hue, sat * 0.12, isDark ? 0.14 : 0.96).toColor();
    final surfaceContainerHighest = HSLColor.fromAHSL(1.0, hue, sat * 0.14, isDark ? 0.18 : 0.98).toColor();

    // Outline
    final outline = HSLColor.fromAHSL(1.0, hue, sat * 0.2, isDark ? 0.25 : 0.55).toColor();
    final outlineVariant = HSLColor.fromAHSL(1.0, hue, sat * 0.1, isDark ? 0.15 : 0.75).toColor();

    return ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: primary,
      onPrimary: _getContrastColor(primary),
      primaryContainer: primaryContainer,
      onPrimaryContainer: _getContrastColor(primaryContainer),
      secondary: secondary,
      onSecondary: _getContrastColor(secondary),
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: _getContrastColor(secondaryContainer),
      tertiary: tertiary,
      onTertiary: _getContrastColor(tertiary),
      error: error,
      onError: _getContrastColor(error),
      errorContainer: errorContainer,
      onErrorContainer: _getContrastColor(errorContainer),
      surface: surface,
      onSurface: isDark ? Colors.white.withValues(alpha: 0.92) : Colors.black.withValues(alpha: 0.87),
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainer,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
      onSurfaceVariant: isDark ? Colors.white.withValues(alpha: 0.70) : Colors.black.withValues(alpha: 0.60),
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: isDark ? Colors.black : Colors.black.withValues(alpha: 0.15),
      scrim: Colors.black,
      inverseSurface: isDark ? surfaceContainerHighest : surfaceContainerLowest,
      onInverseSurface: isDark ? Colors.black : Colors.white,
      inversePrimary: HSLColor.fromAHSL(1.0, hue, sat, isDark ? 0.7 : 0.3).toColor(),
    );
  }

  /// 获取对比色（用于文字）
  Color _getContrastColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// 构建带缩放的 TextTheme
  TextTheme _buildTextTheme(bool isDark, double scale) {
    final base = ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      fontFamily: 'AlimamaFangYuanTi',
    ).textTheme;

    const fontFamily = 'AlimamaFangYuanTi';

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontSize: 57 * scale, fontFamily: fontFamily),
      displayMedium: base.displayMedium?.copyWith(fontSize: 45 * scale, fontFamily: fontFamily),
      displaySmall: base.displaySmall?.copyWith(fontSize: 36 * scale, fontFamily: fontFamily),
      headlineLarge: base.headlineLarge?.copyWith(fontSize: 32 * scale, fontFamily: fontFamily),
      headlineMedium: base.headlineMedium?.copyWith(fontSize: 28 * scale, fontFamily: fontFamily),
      headlineSmall: base.headlineSmall?.copyWith(fontSize: 24 * scale, fontFamily: fontFamily),
      titleLarge: base.titleLarge?.copyWith(fontSize: 22 * scale, fontFamily: fontFamily),
      titleMedium: base.titleMedium?.copyWith(fontSize: 16 * scale, fontFamily: fontFamily),
      titleSmall: base.titleSmall?.copyWith(fontSize: 14 * scale, fontFamily: fontFamily),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 16 * scale, fontFamily: fontFamily),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 14 * scale, fontFamily: fontFamily),
      bodySmall: base.bodySmall?.copyWith(fontSize: 12 * scale, fontFamily: fontFamily),
      labelLarge: base.labelLarge?.copyWith(fontSize: 14 * scale, fontFamily: fontFamily),
      labelMedium: base.labelMedium?.copyWith(fontSize: 12 * scale, fontFamily: fontFamily),
      labelSmall: base.labelSmall?.copyWith(fontSize: 11 * scale, fontFamily: fontFamily),
    );
  }

  /// 根据当前配置生成完整的 ThemeData（shadcn-ui 风格）
  ThemeData toThemeData() {
    final colorScheme = _buildColorScheme(primaryColor, isDark);

    final scaledBorderRadius = borderRadius * uiScale;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: 'AlimamaFangYuanTi',
      // 字体缩放 - 使用自定义 TextTheme
      textTheme: _buildTextTheme(isDark, uiScale),

      // shadcn-ui 风格的卡片主题
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(scaledBorderRadius),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        color: colorScheme.surfaceContainerHigh.withValues(
          alpha: cardOpacity,
        ),
      ),

      // shadcn-ui 风格的 AppBar 主题
      appBarTheme: AppBarTheme(
        centerTitle: false, // shadcn-ui 通常左对齐标题
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20 * uiScale,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          fontFamily: 'AlimamaFangYuanTi',
        ),
      ),

      // shadcn-ui 风格的按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: 24 * uiScale,
            vertical: 12 * uiScale,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(scaledBorderRadius),
          ),
          textStyle: TextStyle(
            fontSize: 14 * uiScale,
            fontWeight: FontWeight.w500,
            fontFamily: 'AlimamaFangYuanTi',
          ),
        ),
      ),

      // shadcn-ui 风格的填充按钮主题
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: 24 * uiScale,
            vertical: 12 * uiScale,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(scaledBorderRadius),
          ),
          textStyle: TextStyle(
            fontSize: 14 * uiScale,
            fontWeight: FontWeight.w500,
            fontFamily: 'AlimamaFangYuanTi',
          ),
        ),
      ),

      // shadcn-ui 风格的轮廓按钮主题
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: 24 * uiScale,
            vertical: 12 * uiScale,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(scaledBorderRadius),
          ),
          side: BorderSide(color: colorScheme.outline, width: 1),
          textStyle: TextStyle(
            fontSize: 14 * uiScale,
            fontWeight: FontWeight.w500,
            fontFamily: 'AlimamaFangYuanTi',
          ),
        ),
      ),

      // shadcn-ui 风格的文本按钮主题
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: 16 * uiScale,
            vertical: 8 * uiScale,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(scaledBorderRadius),
          ),
          textStyle: TextStyle(
            fontSize: 14 * uiScale,
            fontWeight: FontWeight.w500,
            fontFamily: 'AlimamaFangYuanTi',
          ),
        ),
      ),

      // 导航栏主题
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        selectedIconTheme: IconThemeData(
          size: 24 * uiScale,
          color: colorScheme.primary,
        ),
        unselectedIconTheme: IconThemeData(
          size: 24 * uiScale,
          color: colorScheme.onSurfaceVariant,
        ),
        indicatorColor: colorScheme.primary.withValues(alpha: 0.24),
      ),

      // shadcn-ui 风格的输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHigh.withValues(
          alpha: 0.5,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(scaledBorderRadius),
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(scaledBorderRadius),
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(scaledBorderRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * uiScale,
          vertical: 12 * uiScale,
        ),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 14 * uiScale,
          fontFamily: 'AlimamaFangYuanTi',
        ),
      ),

      // shadcn-ui 风格的开关主题
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withValues(alpha: 0.3);
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),

      // shadcn-ui 风格的滑块主题 - 优化为更流畅的交互
      sliderTheme: SliderThemeData(
        trackHeight: 4 * uiScale,
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: 8 * uiScale,
          elevation: 2,
          pressedElevation: 4,
        ),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 20 * uiScale),
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.surfaceContainerHighest,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withValues(alpha: 0.12),
        activeTickMarkColor: Colors.transparent,
        inactiveTickMarkColor: Colors.transparent,
        trackShape: const RoundedRectSliderTrackShape(),
      ),

      // 动画时长
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      // 扩展主题（shadcn-ui 风格）
      extensions: <ThemeExtension<dynamic>>[
        ShardThemeExtension(
          glassBlurSigma: 12.0, // shadcn-ui 风格的模糊强度
          glassBorderWidth: 1.0, // shadcn-ui 风格的细边框
          glowColor: primaryColor, // 使用原始 primary 色
          cardBorderRadius: scaledBorderRadius,
          buttonBorderRadius: scaledBorderRadius,
          inputBorderRadius: scaledBorderRadius,
          animationDurationFactor: 1.0 / animationSpeed,
        ),
      ],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShardTheme &&
        other.isDark == isDark &&
        other.primaryColor == primaryColor &&
        other.cardOpacity == cardOpacity &&
        other.uiScale == uiScale &&
        other.animationSpeed == animationSpeed &&
        other.borderRadius == borderRadius &&
        other.backgroundType == backgroundType &&
        other.backgroundImagePath == backgroundImagePath &&
        other.glassBlurSigma == glassBlurSigma &&
        other.maskOpacity == maskOpacity;
  }

  @override
  int get hashCode {
    return Object.hash(
      isDark,
      primaryColor,
      cardOpacity,
      uiScale,
      animationSpeed,
      borderRadius,
      backgroundType,
      backgroundImagePath,
      glassBlurSigma,
      maskOpacity,
    );
  }
}

// ========================
// ShardThemeExtension - 额外设计 Token
// ========================

/// 主题扩展，存放额外的设计 token
/// 用于玻璃效果、辉光、圆角等高级视觉参数（shadcn-ui 风格）
class ShardThemeExtension extends ThemeExtension<ShardThemeExtension> {
  /// 玻璃模糊强度
  final double glassBlurSigma;

  /// 玻璃边框宽度
  final double glassBorderWidth;

  /// 辉光颜色（基于 primary）
  final Color glowColor;

  /// 卡片基础圆角（随 uiScale 缩放）
  final double cardBorderRadius;

  /// 按钮基础圆角（随 uiScale 缩放）
  final double buttonBorderRadius;

  /// 输入框基础圆角（随 uiScale 缩放）
  final double inputBorderRadius;

  /// 动画时长乘数（1.0 / animationSpeed）
  final double animationDurationFactor;

  const ShardThemeExtension({
    required this.glassBlurSigma,
    required this.glassBorderWidth,
    required this.glowColor,
    required this.cardBorderRadius,
    required this.buttonBorderRadius,
    required this.inputBorderRadius,
    required this.animationDurationFactor,
  });

  @override
  ShardThemeExtension copyWith({
    double? glassBlurSigma,
    double? glassBorderWidth,
    Color? glowColor,
    double? cardBorderRadius,
    double? buttonBorderRadius,
    double? inputBorderRadius,
    double? animationDurationFactor,
  }) {
    return ShardThemeExtension(
      glassBlurSigma: glassBlurSigma ?? this.glassBlurSigma,
      glassBorderWidth: glassBorderWidth ?? this.glassBorderWidth,
      glowColor: glowColor ?? this.glowColor,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      inputBorderRadius: inputBorderRadius ?? this.inputBorderRadius,
      animationDurationFactor:
          animationDurationFactor ?? this.animationDurationFactor,
    );
  }

  @override
  ShardThemeExtension lerp(ShardThemeExtension? other, double t) {
    if (other is! ShardThemeExtension) return this;
    return ShardThemeExtension(
      glassBlurSigma: lerpDouble(glassBlurSigma, other.glassBlurSigma, t),
      glassBorderWidth: lerpDouble(glassBorderWidth, other.glassBorderWidth, t),
      glowColor: Color.lerp(glowColor, other.glowColor, t)!,
      cardBorderRadius: lerpDouble(cardBorderRadius, other.cardBorderRadius, t),
      buttonBorderRadius: lerpDouble(
        buttonBorderRadius,
        other.buttonBorderRadius,
        t,
      ),
      inputBorderRadius: lerpDouble(
        inputBorderRadius,
        other.inputBorderRadius,
        t,
      ),
      animationDurationFactor: lerpDouble(
        animationDurationFactor,
        other.animationDurationFactor,
        t,
      ),
    );
  }

  /// 辅助方法：double 插值
  static double lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
