// ShardXL 玻璃效果卡片组件（shadcn-ui 风格）
// lib/core/widgets/glass_card.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/settings/providers/theme_provider.dart';
import '../theme/shard_theme.dart';

class GlassCard extends ConsumerStatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool showBorder;
  final bool hoverable;

  const GlassCard({
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
  ConsumerState<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends ConsumerState<GlassCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;

  static const Duration _transitionDuration = Duration(milliseconds: 200);
  static const Curve _transitionCurve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(shardThemeProvider);
    final shardTheme = themeState.theme;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();
    final borderRadius = themeExtension?.cardBorderRadius ?? 6.0;

    if (shardTheme.enableGlassEffect) {
      return _buildGlassCard(context, shardTheme, themeExtension, borderRadius);
    } else {
      return _buildNormalCard(context, borderRadius);
    }
  }

  Widget _buildGlassCard(
    BuildContext context,
    ShardTheme shardTheme,
    ShardThemeExtension? themeExtension,
    double borderRadius,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blurSigma = themeExtension?.glassBlurSigma ?? 12.0;
    final borderWidth = themeExtension?.glassBorderWidth ?? 1.0;

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
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
                      width: borderWidth,
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
        ),
      ),
    );
  }

  Widget _buildNormalCard(BuildContext context, double borderRadius) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = isDark
        ? Colors.white.withValues(alpha: _isHovered && widget.hoverable ? 0.12 : 0.06)
        : Colors.black.withValues(alpha: _isHovered && widget.hoverable ? 0.10 : 0.05);

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
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surfaceContainerHigh,
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
