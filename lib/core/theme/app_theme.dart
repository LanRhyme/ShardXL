// ShardXL Dark Theme
// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return FlexThemeData.dark(
      scheme: FlexScheme.deepPurple,
      surfaceMode: FlexSurfaceMode.highScaffoldLevelSurface,
      blendLevel: 15,
      appBarStyle: FlexAppBarStyle.background,
      appBarOpacity: 0.9,
      appBarElevation: 0,
      transparentStatusBar: true,
      tabBarStyle: FlexTabBarStyle.forBackground,
      tooltipsMatchBackground: true,
      swapColors: false,
      darkIsTrueBlack: false,
      useMaterial3: true,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        blendOnColors: false,
        useM2StyleDividerInM3: true,
        defaultRadius: 12.0,
        elevatedButtonRadius: 8.0,
        outlinedButtonRadius: 8.0,
        filledButtonRadius: 8.0,
        inputDecoratorRadius: 8.0,
        inputDecoratorUnfocusedBorderIsColored: false,
        fabRadius: 16.0,
        fabSchemeColor: FlexScheme.primary,
        chipRadius: 8.0,
        popupMenuRadius: 8.0,
        dialogRadius: 16.0,
        dialogBackgroundSchemeColor: FlexScheme.surface,
        useInputDecoratorThemeInDialogs: true,
        snackBarRadius: 8.0,
        snackBarBackgroundSchemeColor: FlexScheme.inverseSurface,
        navigationBarSelectedLabelSchemeColor: FlexScheme.primary,
        navigationBarUnselectedLabelSchemeColor: FlexScheme.onSurface,
        navigationBarIndicatorSchemeColor: FlexScheme.primary,
        navigationBarIndicatorOpacity: 0.24,
        navigationRailSelectedLabelSchemeColor: FlexScheme.primary,
        navigationRailUnselectedLabelSchemeColor: FlexScheme.onSurface,
        navigationRailIndicatorSchemeColor: FlexScheme.primary,
        navigationRailIndicatorOpacity: 0.24,
      ),
    );
  }

  // ShardXL Brand Colors
  static const Color primaryBrand = Color(0xFF7C4DFF);   // Deep Purple A200
  static const Color accentBrand  = Color(0xFF00E5FF);    // Cyan A400
  static const Color surfaceDark  = Color(0xFF1A1A2E);    // Dark surface
  static const Color surfaceCard = Color(0xFF16213E);    // Card surface
  static const Color mcGrassGreen= Color(0xFF4CAF50);    // Minecraft grass
  static const Color mcDirtBrown = Color(0xFF8D6E63);    // Minecraft dirt
}
