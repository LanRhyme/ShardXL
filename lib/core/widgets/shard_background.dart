// ShardXL 动态背景组件
// lib/core/widgets/shard_background.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/settings/providers/theme_provider.dart';

/// 动态背景组件
/// 根据主题配置显示不同类型的背景
class ShardBackground extends ConsumerWidget {
  final Widget child;

  const ShardBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(shardThemeProvider);
    final shardTheme = themeState.theme;
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // 背景层
        Positioned.fill(
          child: _buildBackground(
            colorScheme,
            shardTheme.primaryColor,
            shardTheme.backgroundType,
          ),
        ),
        // 内容层
        child,
      ],
    );
  }

  /// 根据背景类型构建不同的背景
  Widget _buildBackground(ColorScheme colorScheme, Color primaryColor, String backgroundType) {
    switch (backgroundType) {
      case 'solid':
        return Container(color: colorScheme.surfaceContainerLowest);

      case 'gradient':
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surfaceContainerLowest,
                colorScheme.surfaceContainer,
                Color.lerp(
                  colorScheme.surfaceContainerLowest,
                  primaryColor,
                  0.08,
                )!,
              ],
            ),
          ),
        );

      case 'image':
        // 图片背景占位（可扩展）
        // 注意：需要在 assets/images/ 下放置 background.png 文件
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            // 暂时使用渐变作为 fallback，图片文件存在时启用
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.surfaceContainerLowest,
                colorScheme.surfaceContainer,
              ],
            ),
          ),
        );

      case 'dynamic':
        // 动态渐变背景（赛博朋克风格）
        return _DynamicBackground(primaryColor: primaryColor);

      default:
        return Container(color: colorScheme.surfaceContainerLowest);
    }
  }
}

/// 动态渐变背景（赛博朋克风格）
class _DynamicBackground extends StatefulWidget {
  final Color primaryColor;

  const _DynamicBackground({required this.primaryColor});

  @override
  State<_DynamicBackground> createState() => _DynamicBackgroundState();
}

class _DynamicBackgroundState extends State<_DynamicBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surfaceContainerLowest,
                Color.lerp(
                  colorScheme.surfaceContainerLowest,
                  widget.primaryColor,
                  0.05 + (_controller.value * 0.05),
                )!,
                colorScheme.surfaceContainer,
                Color.lerp(
                  colorScheme.surfaceContainerLowest,
                  widget.primaryColor,
                  0.08 - (_controller.value * 0.03),
                )!,
              ],
              stops: [
                0.0,
                0.3 + (_controller.value * 0.1),
                0.7 - (_controller.value * 0.1),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}