// ShardXL 玻璃效果卡片组件
// lib/core/widgets/glass_card.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/settings/providers/theme_provider.dart';
import '../theme/shard_theme.dart';

/// 毛玻璃效果卡片组件
/// 根据主题配置自动启用/禁用玻璃效果
class GlassCard extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(shardThemeProvider);
    final shardTheme = themeState.theme;
    final themeExtension =
        Theme.of(context).extension<ShardThemeExtension>();

    final borderRadius =
        BorderRadius.circular(themeExtension?.cardBorderRadius ?? 16.0);

    // 根据是否启用玻璃效果选择不同的卡片样式
    if (shardTheme.enableGlassEffect) {
      return _buildGlassCard(context, shardTheme, themeExtension, borderRadius);
    } else {
      return _buildNormalCard(context, borderRadius);
    }
  }

  /// 构建玻璃效果卡片
  Widget _buildGlassCard(
    BuildContext context,
    ShardTheme shardTheme,
    ShardThemeExtension? themeExtension,
    BorderRadius borderRadius,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final blurSigma = themeExtension?.glassBlurSigma ?? 20.0;
    final borderWidth = themeExtension?.glassBorderWidth ?? 1.5;
    final glowColor = themeExtension?.glowColor ?? colorScheme.primary;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          // 基于 primary 的轻微辉光阴影
          BoxShadow(
            color: glowColor.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: colorScheme.surfaceContainerHigh
                  .withValues(alpha: shardTheme.cardOpacity),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: borderWidth,
              ),
            ),
            padding: padding ?? const EdgeInsets.all(16),
            child: onTap != null
                ? InkWell(
                    onTap: onTap,
                    borderRadius: borderRadius,
                    child: child,
                  )
                : child,
          ),
        ),
      ),
    );
  }

  /// 构建普通卡片（关闭玻璃效果时的 fallback）
  Widget _buildNormalCard(BuildContext context, BorderRadius borderRadius) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: margin,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      color: colorScheme.surfaceContainerHigh,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}