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
  
  /// 启用毛玻璃效果（默认 true）
  final bool enableGlassEffect;
  
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

  const ShardTheme({
    this.isDark = true,
    this.primaryColor = const Color(0xFF7C4DFF), // Deep Purple A200
    this.enableGlassEffect = true,
    this.cardOpacity = 0.65,
    this.uiScale = 1.0,
    this.animationSpeed = 1.0,
    this.borderRadius = 10.0, // shadcn-ui 风格圆角
    this.backgroundType = 'solid',
    this.backgroundImagePath,
  });

  // ========================
  // 复制方法
  // ========================
  
  ShardTheme copyWith({
    bool? isDark,
    Color? primaryColor,
    bool? enableGlassEffect,
    double? cardOpacity,
    double? uiScale,
    double? animationSpeed,
    double? borderRadius,
    String? backgroundType,
    String? backgroundImagePath,
  }) {
    return ShardTheme(
      isDark: isDark ?? this.isDark,
      primaryColor: primaryColor ?? this.primaryColor,
      enableGlassEffect: enableGlassEffect ?? this.enableGlassEffect,
      cardOpacity: cardOpacity ?? this.cardOpacity,
      uiScale: uiScale ?? this.uiScale,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      borderRadius: borderRadius ?? this.borderRadius,
      backgroundType: backgroundType ?? this.backgroundType,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
    );
  }

  // ========================
  // 序列化方法
  // ========================
  
  Map<String, dynamic> toMap() {
    return {
      'isDark': isDark,
      'primaryColor': primaryColor.toARGB32(),
      'enableGlassEffect': enableGlassEffect,
      'cardOpacity': cardOpacity,
      'uiScale': uiScale,
      'animationSpeed': animationSpeed,
      'borderRadius': borderRadius,
      'backgroundType': backgroundType,
      'backgroundImagePath': backgroundImagePath,
    };
  }

  factory ShardTheme.fromMap(Map<String, dynamic> map) {
    return ShardTheme(
      isDark: map['isDark'] ?? true,
      primaryColor: Color(map['primaryColor'] ?? 0xFF7C4DFF),
      enableGlassEffect: map['enableGlassEffect'] ?? true,
      cardOpacity: (map['cardOpacity'] ?? 0.65).toDouble(),
      uiScale: (map['uiScale'] ?? 1.0).toDouble(),
      animationSpeed: (map['animationSpeed'] ?? 1.0).toDouble(),
      borderRadius: (map['borderRadius'] ?? 10.0).toDouble(),
      backgroundType: map['backgroundType'] ?? 'gradient',
      backgroundImagePath: map['backgroundImagePath'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory ShardTheme.fromJson(String source) =>
      ShardTheme.fromMap(json.decode(source));

  // ========================
  // 生成 Material 3 ThemeData
  // ========================

  /// 基于 primaryColor 动态生成和谐的深色配色方案
  /// 
  /// 使用 HSL 颜色空间，从 primaryColor 提取色相，
  /// 然后生成低饱和度、低亮度的 surface 颜色
  ColorScheme _buildDarkColorScheme(ColorScheme base, Color primary) {
    final hsl = HSLColor.fromColor(primary);
    final hue = hsl.hue;
    final sat = hsl.saturation;

    // 背景层：极低饱和度，深色调
    final surfaceContainerLowest = HSLColor.fromAHSL(
      1.0,
      hue,
      sat * 0.08,  // 8% 原始饱和度
      0.06,        // 6% 亮度
    ).toColor();

    // surface 层：略微带色
    final surfaceContainer = HSLColor.fromAHSL(
      1.0,
      hue,
      sat * 0.10,
      0.10,
    ).toColor();

    // 卡片层：稍亮
    final surfaceContainerHigh = HSLColor.fromAHSL(
      1.0,
      hue,
      sat * 0.12,
      0.14,
    ).toColor();

    // 最高层：用于悬浮元素
    final surfaceContainerHighest = HSLColor.fromAHSL(
      1.0,
      hue,
      sat * 0.14,
      0.18,
    ).toColor();

    // surface 主色
    final surface = HSLColor.fromAHSL(
      1.0,
      hue,
      sat * 0.10,
      0.09,
    ).toColor();

    return base.copyWith(
      surface: surface,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
      // 保持良好的文字对比度
      onSurface: Colors.white.withValues(alpha: 0.92),
      onSurfaceVariant: Colors.white.withValues(alpha: 0.70),
    );
  }

  /// 基于 primaryColor 动态生成和谐的浅色配色方案
  /// 
  /// 浅色模式层级：background(最深) → surface → card(最浅/最突出)
  ColorScheme _buildLightColorScheme(ColorScheme base, Color primary) {
    final hsl = HSLColor.fromColor(primary);
    final hue = hsl.hue;
    final sat = hsl.saturation;

    // 浅色模式：背景最深，层级越高颜色越浅（越突出）
    final surfaceContainerLowest = HSLColor.fromAHSL(
      1.0,
      hue,
      sat * 0.06,
      0.91,  // 最深，作为背景
    ).toColor();

    final surfaceContainer = HSLColor.fromAHSL(
      1.0,
      hue,
      sat * 0.05,
      0.94,  // 稍浅
    ).toColor();

    final surfaceContainerHigh = HSLColor.fromAHSL(
      1.0,
      hue,
      sat * 0.04,
      0.96,  // 更浅，用于卡片
    ).toColor();

    final surfaceContainerHighest = HSLColor.fromAHSL(
      1.0,
      hue,
      sat * 0.03,
      0.98,  // 最浅，最突出
    ).toColor();

    final surface = HSLColor.fromAHSL(
      1.0,
      hue,
      sat * 0.05,
      0.93,  // 介于 background 和 card 之间
    ).toColor();

    return base.copyWith(
      surface: surface,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
    );
  }

  /// 构建带缩放的 TextTheme
  TextTheme _buildTextTheme(bool isDark, double scale) {
    final base = ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
    ).textTheme;

    // 使用 copyWith 逐个设置 fontSize，避免 apply(fontSizeFactor:) 的断言问题
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontSize: 57 * scale),
      displayMedium: base.displayMedium?.copyWith(fontSize: 45 * scale),
      displaySmall: base.displaySmall?.copyWith(fontSize: 36 * scale),
      headlineLarge: base.headlineLarge?.copyWith(fontSize: 32 * scale),
      headlineMedium: base.headlineMedium?.copyWith(fontSize: 28 * scale),
      headlineSmall: base.headlineSmall?.copyWith(fontSize: 24 * scale),
      titleLarge: base.titleLarge?.copyWith(fontSize: 22 * scale),
      titleMedium: base.titleMedium?.copyWith(fontSize: 16 * scale),
      titleSmall: base.titleSmall?.copyWith(fontSize: 14 * scale),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 16 * scale),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 14 * scale),
      bodySmall: base.bodySmall?.copyWith(fontSize: 12 * scale),
      labelLarge: base.labelLarge?.copyWith(fontSize: 14 * scale),
      labelMedium: base.labelMedium?.copyWith(fontSize: 12 * scale),
      labelSmall: base.labelSmall?.copyWith(fontSize: 11 * scale),
    );
  }
  
  /// 根据当前配置生成完整的 ThemeData（shadcn-ui 风格）
  ThemeData toThemeData() {
    // 根据 primaryColor 生成完整的 ColorScheme
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );

    // 深色/浅色模式下的自定义 surface 颜色（基于 primaryColor 动态生成）
    final effectiveColorScheme = isDark
        ? _buildDarkColorScheme(colorScheme, primaryColor)
        : _buildLightColorScheme(colorScheme, primaryColor);

    // shadcn-ui 风格的圆角系统
    final scaledBorderRadius = borderRadius * uiScale;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: effectiveColorScheme,
      scaffoldBackgroundColor: Colors.transparent,
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
        color: enableGlassEffect
            ? effectiveColorScheme.surfaceContainerHigh.withValues(alpha: cardOpacity)
            : effectiveColorScheme.surfaceContainerHigh,
      ),
      
      // shadcn-ui 风格的 AppBar 主题
      appBarTheme: AppBarTheme(
        centerTitle: false, // shadcn-ui 通常左对齐标题
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20 * uiScale,
          fontWeight: FontWeight.w600,
          color: effectiveColorScheme.onSurface,
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
          side: BorderSide(
            color: effectiveColorScheme.outline,
            width: 1,
          ),
          textStyle: TextStyle(
            fontSize: 14 * uiScale,
            fontWeight: FontWeight.w500,
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
          ),
        ),
      ),
      
      // 导航栏主题
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: effectiveColorScheme.surfaceContainerLowest,
        selectedIconTheme: IconThemeData(
          size: 24 * uiScale,
          color: effectiveColorScheme.primary,
        ),
        unselectedIconTheme: IconThemeData(
          size: 24 * uiScale,
          color: effectiveColorScheme.onSurfaceVariant,
        ),
        indicatorColor: effectiveColorScheme.primary.withValues(alpha: 0.24),
      ),
      
      // shadcn-ui 风格的输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: effectiveColorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(scaledBorderRadius),
          borderSide: BorderSide(
            color: effectiveColorScheme.outline,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(scaledBorderRadius),
          borderSide: BorderSide(
            color: effectiveColorScheme.outline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(scaledBorderRadius),
          borderSide: BorderSide(
            color: effectiveColorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * uiScale,
          vertical: 12 * uiScale,
        ),
        hintStyle: TextStyle(
          color: effectiveColorScheme.onSurfaceVariant,
          fontSize: 14 * uiScale,
        ),
      ),
      
      // shadcn-ui 风格的开关主题
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return effectiveColorScheme.primary;
          }
          return effectiveColorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return effectiveColorScheme.primary.withValues(alpha: 0.3);
          }
          return effectiveColorScheme.surfaceContainerHighest;
        }),
      ),
      
      // shadcn-ui 风格的滑块主题
      sliderTheme: SliderThemeData(
        trackHeight: 4 * uiScale,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8 * uiScale),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 16 * uiScale),
        activeTrackColor: effectiveColorScheme.primary,
        inactiveTrackColor: effectiveColorScheme.surfaceContainerHighest,
        thumbColor: effectiveColorScheme.primary,
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
          glassBlurSigma: 12.0,        // shadcn-ui 风格的模糊强度
          glassBorderWidth: 1.0,       // shadcn-ui 风格的细边框
          glowColor: primaryColor,      // 使用原始 primary 色
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
        other.enableGlassEffect == enableGlassEffect &&
        other.cardOpacity == cardOpacity &&
        other.uiScale == uiScale &&
        other.animationSpeed == animationSpeed &&
        other.borderRadius == borderRadius &&
        other.backgroundType == backgroundType &&
        other.backgroundImagePath == backgroundImagePath;
  }

  @override
  int get hashCode {
    return Object.hash(
      isDark,
      primaryColor,
      enableGlassEffect,
      cardOpacity,
      uiScale,
      animationSpeed,
      borderRadius,
      backgroundType,
      backgroundImagePath,
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
  ShardThemeExtension lerp(
    ShardThemeExtension? other,
    double t,
  ) {
    if (other is! ShardThemeExtension) return this;
    return ShardThemeExtension(
      glassBlurSigma: lerpDouble(glassBlurSigma, other.glassBlurSigma, t),
      glassBorderWidth: lerpDouble(glassBorderWidth, other.glassBorderWidth, t),
      glowColor: Color.lerp(glowColor, other.glowColor, t)!,
      cardBorderRadius: lerpDouble(cardBorderRadius, other.cardBorderRadius, t),
      buttonBorderRadius: lerpDouble(buttonBorderRadius, other.buttonBorderRadius, t),
      inputBorderRadius: lerpDouble(inputBorderRadius, other.inputBorderRadius, t),
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