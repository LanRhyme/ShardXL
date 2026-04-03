// ShardXL shadcn-ui 风格按钮组件
// lib/core/widgets/shadcn_button.dart

import 'package:flutter/material.dart';
import '../theme/shard_theme.dart';

enum ShadcnButtonVariant {
  default_,
  secondary,
  destructive,
  outline,
  ghost,
  link,
}

enum ShadcnButtonSize {
  default_,
  sm,
  lg,
  icon,
}

class ShadcnButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ShadcnButtonVariant variant;
  final ShadcnButtonSize size;
  final bool disabled;
  final bool loading;
  final IconData? icon;
  final IconData? iconRight;
  final FocusNode? focusNode;

  const ShadcnButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = ShadcnButtonVariant.default_,
    this.size = ShadcnButtonSize.default_,
    this.disabled = false,
    this.loading = false,
    this.icon,
    this.iconRight,
    this.focusNode,
  });

  @override
  State<ShadcnButton> createState() => _ShadcnButtonState();
}

class _ShadcnButtonState extends State<ShadcnButton>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  bool _isHovered = false;
  bool _isPressed = false;

  static const Duration _transitionDuration = Duration(milliseconds: 150);
  static const Curve _transitionCurve = Curves.easeOut;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  bool get _isEnabled => !widget.disabled && !widget.loading;
  bool get _isFocused => _focusNode.hasFocus;

  void _handleTapDown(TapDownDetails details) {
    if (_isEnabled) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  void _handleHover(bool isHovered) {
    if (_isEnabled) {
      setState(() => _isHovered = isHovered);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeExtension = theme.extension<ShardThemeExtension>();
    final borderRadius = themeExtension?.buttonBorderRadius ?? 6.0;

    final colors = _getButtonColors(colorScheme);
    final padding = _getPadding();
    final textStyle = _getTextStyle(theme);

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _isEnabled ? widget.onPressed : null,
        child: MouseRegion(
          onEnter: (_) => _handleHover(true),
          onExit: (_) => _handleHover(false),
          cursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: Focus(
            focusNode: _focusNode,
            child: AnimatedContainer(
              duration: _transitionDuration,
              curve: _transitionCurve,
              padding: padding,
              decoration: _buildDecoration(colors, borderRadius),
              child: _buildChild(textStyle, colors),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(_ButtonColors colors, double borderRadius) {
    Color bgColor = colors.background;
    Color borderColor = colors.border ?? Colors.transparent;

    if (_isHovered && _isEnabled) {
      bgColor = colors.backgroundHover ?? bgColor;
      borderColor = colors.borderHover ?? borderColor;
    }

    if (!_isEnabled) {
      bgColor = colors.backgroundDisabled;
      borderColor = colors.borderDisabled ?? borderColor;
    }

    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: colors.border != null || colors.borderDisabled != null
          ? Border.all(
              color: borderColor,
              width: 1,
            )
          : null,
      boxShadow: _buildBoxShadow(colors),
    );
  }

  List<BoxShadow>? _buildBoxShadow(_ButtonColors colors) {
    if (!_isEnabled) return null;

    if (widget.variant == ShadcnButtonVariant.default_ ||
        widget.variant == ShadcnButtonVariant.destructive) {
      return [
        BoxShadow(
          color: colors.background.withValues(alpha: _isHovered ? 0.3 : 0.15),
          blurRadius: _isHovered ? 8 : 4,
          offset: const Offset(0, 2),
        ),
      ];
    }

    if (_isFocused && widget.variant != ShadcnButtonVariant.ghost) {
      return [
        BoxShadow(
          color: colors.foreground.withValues(alpha: 0.2),
          blurRadius: 0,
          spreadRadius: 2,
        ),
      ];
    }

    return null;
  }

  Widget _buildChild(TextStyle textStyle, _ButtonColors colors) {
    final effectiveColor = !_isEnabled
        ? colors.foregroundDisabled
        : (_isHovered ? (colors.foregroundHover ?? colors.foreground) : colors.foreground);

    if (widget.loading) {
      return SizedBox(
        width: _getLoadingSize(),
        height: _getLoadingSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
        ),
      );
    }

    final textWidget = DefaultTextStyle(
      style: textStyle.copyWith(color: effectiveColor),
      child: widget.child,
    );

    if (widget.icon != null && widget.iconRight != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: textStyle.fontSize! + 2, color: effectiveColor),
          const SizedBox(width: 8),
          textWidget,
          const SizedBox(width: 8),
          Icon(widget.iconRight, size: textStyle.fontSize! + 2, color: effectiveColor),
        ],
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: textStyle.fontSize! + 2, color: effectiveColor),
          const SizedBox(width: 8),
          textWidget,
        ],
      );
    }

    if (widget.iconRight != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          textWidget,
          const SizedBox(width: 8),
          Icon(widget.iconRight, size: textStyle.fontSize! + 2, color: effectiveColor),
        ],
      );
    }

    return textWidget;
  }

  double _getLoadingSize() {
    switch (widget.size) {
      case ShadcnButtonSize.sm:
        return 14;
      case ShadcnButtonSize.lg:
        return 20;
      default:
        return 16;
    }
  }

  _ButtonColors _getButtonColors(ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (widget.variant) {
      case ShadcnButtonVariant.default_:
        return _ButtonColors(
          background: colorScheme.primary,
          backgroundHover: isDark
              ? HSLColor.fromColor(colorScheme.primary).withLightness(0.55).toColor()
              : HSLColor.fromColor(colorScheme.primary).withLightness(0.45).toColor(),
          foreground: colorScheme.onPrimary,
          foregroundHover: colorScheme.onPrimary,
          backgroundDisabled: colorScheme.primary.withValues(alpha: 0.5),
          foregroundDisabled: colorScheme.onPrimary.withValues(alpha: 0.5),
        );

      case ShadcnButtonVariant.secondary:
        return _ButtonColors(
          background: isDark
              ? colorScheme.onSurface.withValues(alpha: 0.08)
              : colorScheme.onSurface.withValues(alpha: 0.06),
          backgroundHover: isDark
              ? colorScheme.onSurface.withValues(alpha: 0.12)
              : colorScheme.onSurface.withValues(alpha: 0.10),
          foreground: colorScheme.onSurface,
          foregroundHover: colorScheme.onSurface,
          backgroundDisabled: colorScheme.onSurface.withValues(alpha: 0.04),
          foregroundDisabled: colorScheme.onSurface.withValues(alpha: 0.4),
        );

      case ShadcnButtonVariant.destructive:
        return _ButtonColors(
          background: colorScheme.error,
          backgroundHover: isDark
              ? HSLColor.fromColor(colorScheme.error).withLightness(0.45).toColor()
              : HSLColor.fromColor(colorScheme.error).withLightness(0.40).toColor(),
          foreground: colorScheme.onError,
          foregroundHover: colorScheme.onError,
          backgroundDisabled: colorScheme.error.withValues(alpha: 0.5),
          foregroundDisabled: colorScheme.onError.withValues(alpha: 0.5),
        );

      case ShadcnButtonVariant.outline:
        return _ButtonColors(
          background: Colors.transparent,
          backgroundHover: colorScheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.04),
          foreground: colorScheme.onSurface,
          foregroundHover: colorScheme.onSurface,
          border: colorScheme.outline.withValues(alpha: isDark ? 0.3 : 0.5),
          borderHover: colorScheme.outline.withValues(alpha: isDark ? 0.5 : 0.7),
          backgroundDisabled: Colors.transparent,
          foregroundDisabled: colorScheme.onSurface.withValues(alpha: 0.4),
          borderDisabled: colorScheme.outline.withValues(alpha: 0.2),
        );

      case ShadcnButtonVariant.ghost:
        return _ButtonColors(
          background: Colors.transparent,
          backgroundHover: colorScheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.06),
          foreground: colorScheme.onSurface,
          foregroundHover: colorScheme.onSurface,
          backgroundDisabled: Colors.transparent,
          foregroundDisabled: colorScheme.onSurface.withValues(alpha: 0.4),
        );

      case ShadcnButtonVariant.link:
        return _ButtonColors(
          background: Colors.transparent,
          backgroundHover: Colors.transparent,
          foreground: colorScheme.primary,
          foregroundHover: colorScheme.primary.withValues(alpha: 0.8),
          backgroundDisabled: Colors.transparent,
          foregroundDisabled: colorScheme.primary.withValues(alpha: 0.4),
        );
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (widget.size) {
      case ShadcnButtonSize.default_:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case ShadcnButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case ShadcnButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
      case ShadcnButtonSize.icon:
        return const EdgeInsets.all(10);
    }
  }

  TextStyle _getTextStyle(ThemeData theme) {
    final baseStyle = theme.textTheme.labelLarge ?? const TextStyle();
    switch (widget.size) {
      case ShadcnButtonSize.default_:
        return baseStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.0);
      case ShadcnButtonSize.sm:
        return baseStyle.copyWith(fontSize: 12.5, fontWeight: FontWeight.w500, letterSpacing: 0.0);
      case ShadcnButtonSize.lg:
        return baseStyle.copyWith(fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: 0.0);
      case ShadcnButtonSize.icon:
        return baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w500);
    }
  }
}

class _ButtonColors {
  final Color background;
  final Color? backgroundHover;
  final Color foreground;
  final Color? foregroundHover;
  final Color? border;
  final Color? borderHover;
  final Color backgroundDisabled;
  final Color foregroundDisabled;
  final Color? borderDisabled;

  const _ButtonColors({
    required this.background,
    this.backgroundHover,
    required this.foreground,
    this.foregroundHover,
    this.border,
    this.borderHover,
    required this.backgroundDisabled,
    required this.foregroundDisabled,
    this.borderDisabled,
  });
}

class ShadcnIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final ShadcnButtonVariant variant;
  final double? size;
  final bool disabled;
  final String? tooltip;

  const ShadcnIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = ShadcnButtonVariant.ghost,
    this.size,
    this.disabled = false,
    this.tooltip,
  });

  @override
  State<ShadcnIconButton> createState() => _ShadcnIconButtonState();
}

class _ShadcnIconButtonState extends State<ShadcnIconButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeExtension = theme.extension<ShardThemeExtension>();
    final borderRadius = themeExtension?.buttonBorderRadius ?? 6.0;
    final isDark = theme.brightness == Brightness.dark;
    final isEnabled = !widget.disabled;

    Color bgColor;
    Color? hoverColor;
    Color fgColor;

    switch (widget.variant) {
      case ShadcnButtonVariant.default_:
        bgColor = colorScheme.primary;
        hoverColor = isDark
            ? HSLColor.fromColor(colorScheme.primary).withLightness(0.55).toColor()
            : HSLColor.fromColor(colorScheme.primary).withLightness(0.45).toColor();
        fgColor = colorScheme.onPrimary;
        break;
      case ShadcnButtonVariant.outline:
        bgColor = Colors.transparent;
        hoverColor = colorScheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.04);
        fgColor = colorScheme.onSurface;
        break;
      case ShadcnButtonVariant.ghost:
      default:
        bgColor = Colors.transparent;
        hoverColor = colorScheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.06);
        fgColor = colorScheme.onSurface;
    }

    final button = GestureDetector(
      onTapDown: isEnabled
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: isEnabled
          ? (_) => setState(() => _isPressed = false)
          : null,
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: isEnabled ? widget.onPressed : null,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isHovered && isEnabled ? hoverColor : bgColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: widget.variant == ShadcnButtonVariant.outline
                  ? Border.all(
                      color: colorScheme.outline.withValues(alpha: _isHovered ? 0.5 : 0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Icon(
              widget.icon,
              size: widget.size ?? 20,
              color: isEnabled
                  ? fgColor
                  : fgColor.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        preferBelow: false,
        child: button,
      );
    }

    return button;
  }
}
