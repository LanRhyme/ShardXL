// ShardXL 玻璃效果卡片组件（shadcn-ui 风格）
// lib/core/widgets/glass_card.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/settings/providers/theme_provider.dart';
import '../theme/shard_theme.dart';

/// 毛玻璃效果卡片组件（shadcn-ui 风格）
/// 根据主题配置自动启用/禁用玻璃效果
class GlassCard extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool showBorder;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(shardThemeProvider);
    final shardTheme = themeState.theme;
    final themeExtension =
        Theme.of(context).extension<ShardThemeExtension>();

    final borderRadius =
        BorderRadius.circular(themeExtension?.cardBorderRadius ?? 10.0);

    // 根据是否启用玻璃效果选择不同的卡片样式
    if (shardTheme.enableGlassEffect) {
      return _buildGlassCard(context, shardTheme, themeExtension, borderRadius);
    } else {
      return _buildNormalCard(context, borderRadius);
    }
  }

  /// 构建玻璃效果卡片（shadcn-ui 风格）
  Widget _buildGlassCard(
    BuildContext context,
    ShardTheme shardTheme,
    ShardThemeExtension? themeExtension,
    BorderRadius borderRadius,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blurSigma = themeExtension?.glassBlurSigma ?? 12.0;
    final borderWidth = themeExtension?.glassBorderWidth ?? 1.0;

    // shadcn-ui 风格的边框颜色
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.1);

    // 卡片背景色
    final cardColor = isDark
        ? colorScheme.surfaceContainerHigh.withValues(alpha: shardTheme.cardOpacity)
        : colorScheme.surfaceContainerHigh.withValues(alpha: shardTheme.cardOpacity + 0.1);

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: showBorder
                  ? Border.all(
                      color: borderColor,
                      width: borderWidth,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      color: cardColor,
                    ),
                  ),
                ),
                // shadcn-ui 风格的微妙渐变
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [
                                Colors.white.withValues(alpha: 0.03),
                                Colors.white.withValues(alpha: 0.0),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.5),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                        stops: const [0.0, 0.3],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: onTap != null
                      ? InkWell(
                          onTap: onTap,
                          borderRadius: borderRadius,
                          splashColor: colorScheme.primary.withValues(alpha: 0.1),
                          highlightColor: colorScheme.primary.withValues(alpha: 0.05),
                          child: child,
                        )
                      : child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建普通卡片（shadcn-ui 风格）
  Widget _buildNormalCard(BuildContext context, BorderRadius borderRadius) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: colorScheme.surfaceContainerHigh,
        border: showBorder
            ? Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
                width: 1,
              )
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}