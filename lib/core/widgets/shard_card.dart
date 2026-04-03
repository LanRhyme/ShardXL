// ShardXL 卡片组件（shadcn-ui 风格）
// lib/core/widgets/shard_card.dart
//
// 负责显示半透明卡片样式

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/settings/providers/theme_provider.dart';
import '../theme/shard_theme.dart';

class ShardCard extends ConsumerStatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool showBorder;
  final bool hoverable;

  const ShardCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.showBorder = true,
    this.hoverable = false,
  });

  @override
  ConsumerState<ShardCard> createState() => _ShardCardState();
}

class _ShardCardState extends ConsumerState<ShardCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;

  static const Duration _transitionDuration = Duration(milliseconds: 200);
  static const Curve _transitionCurve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final shardTheme = ref.watch(shardThemeProvider).theme;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();
    final borderRadius = themeExtension?.cardBorderRadius ?? 6.0;

    return _buildCard(context, shardTheme, borderRadius);
  }

  Widget _buildCard(BuildContext context, ShardTheme shardTheme, double borderRadius) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = isDark
        ? Colors.white.withValues(alpha: _isHovered && widget.hoverable ? 0.15 : 0.08)
        : Colors.black.withValues(alpha: _isHovered && widget.hoverable ? 0.12 : 0.06);

    final cardColor = isDark
        ? colorScheme.surfaceContainerHigh.withValues(alpha: shardTheme.cardOpacity)
        : colorScheme.surfaceContainerHigh.withValues(alpha: shardTheme.cardOpacity + 0.1);

    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: AnimatedContainer(
        duration: _transitionDuration,
        curve: _transitionCurve,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: _isHovered && widget.hoverable
              ? cardColor.withValues(alpha: (shardTheme.cardOpacity + 0.05).clamp(0.0, 1.0))
              : cardColor,
          border: widget.showBorder
              ? Border.all(
                  color: borderColor,
                  width: 1,
                )
              : null,
          boxShadow: _buildBoxShadow(isDark),
        ),
        child: MouseRegion(
          onEnter: widget.hoverable ? (_) => _setHovered(true) : null,
          onExit: widget.hoverable ? (_) => _setHovered(false) : null,
          child: GestureDetector(
            onTapDown: widget.onTap != null ? (_) => _setPressed(true) : null,
            onTapUp: widget.onTap != null ? (_) => _setPressed(false) : null,
            onTapCancel: widget.onTap != null ? () => _setPressed(false) : null,
            onTap: widget.onTap,
            child: AnimatedScale(
              scale: _isPressed ? 0.995 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.all(16),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BoxShadow>? _buildBoxShadow(bool isDark) {
    if (!_isHovered || !widget.hoverable) return null;

    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.black.withValues(alpha: 0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  void _setHovered(bool value) {
    if (mounted) {
      setState(() => _isHovered = value);
    }
  }

  void _setPressed(bool value) {
    if (mounted) {
      setState(() => _isPressed = value);
    }
  }
}
