// ShardXL shadcn-ui 风格按钮组件
// lib/core/widgets/shadcn_button.dart

import 'package:flutter/material.dart';
import '../theme/shard_theme.dart';

/// shadcn-ui 风格的按钮变体
enum ShadcnButtonVariant {
  default_,
  secondary,
  destructive,
  outline,
  ghost,
  link,
}

/// shadcn-ui 风格的按钮尺寸
enum ShadcnButtonSize {
  default_,
  sm,
  lg,
  icon,
}

/// shadcn-ui 风格的按钮组件
class ShadcnButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ShadcnButtonVariant variant;
  final ShadcnButtonSize size;
  final bool disabled;
  final bool loading;
  final IconData? icon;
  final IconData? iconRight;

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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeExtension = theme.extension<ShardThemeExtension>();
    final borderRadius = BorderRadius.circular(
      themeExtension?.buttonBorderRadius ?? 10.0,
    );

    // 根据变体和尺寸确定样式
    final buttonStyle = _getButtonStyle(colorScheme, borderRadius);
    final padding = _getPadding();
    final textStyle = _getTextStyle(theme);

    return ElevatedButton(
      onPressed: disabled || loading ? null : onPressed,
      style: buttonStyle,
      child: _buildChild(textStyle),
    );
  }

  /// 根据变体获取按钮样式
  ButtonStyle _getButtonStyle(ColorScheme colorScheme, BorderRadius borderRadius) {
    switch (variant) {
      case ShadcnButtonVariant.default_:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.5),
          disabledForegroundColor: colorScheme.onPrimary.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );
      case ShadcnButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          disabledBackgroundColor: colorScheme.secondary.withValues(alpha: 0.5),
          disabledForegroundColor: colorScheme.onSecondary.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );
      case ShadcnButtonVariant.destructive:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.error,
          foregroundColor: colorScheme.onError,
          disabledBackgroundColor: colorScheme.error.withValues(alpha: 0.5),
          disabledForegroundColor: colorScheme.onError.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );
      case ShadcnButtonVariant.outline:
        return OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: colorScheme.onSurface,
          disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          side: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
        );
      case ShadcnButtonVariant.ghost:
        return TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: colorScheme.onSurface,
          disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );
      case ShadcnButtonVariant.link:
        return TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: colorScheme.primary,
          disabledForegroundColor: colorScheme.primary.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );
    }
  }

  /// 根据尺寸获取内边距
  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case ShadcnButtonSize.default_:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ShadcnButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case ShadcnButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ShadcnButtonSize.icon:
        return const EdgeInsets.all(8);
    }
  }

  /// 获取文本样式
  TextStyle _getTextStyle(ThemeData theme) {
    final baseStyle = theme.textTheme.labelLarge ?? const TextStyle();
    switch (size) {
      case ShadcnButtonSize.default_:
        return baseStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500);
      case ShadcnButtonSize.sm:
        return baseStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w500);
      case ShadcnButtonSize.lg:
        return baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w500);
      case ShadcnButtonSize.icon:
        return baseStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w500);
    }
  }

  /// 构建按钮内容
  Widget _buildChild(TextStyle textStyle) {
    if (loading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            textStyle.color ?? Colors.white,
          ),
        ),
      );
    }

    if (icon != null && iconRight != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: textStyle.fontSize),
          const SizedBox(width: 8),
          child,
          const SizedBox(width: 8),
          Icon(iconRight, size: textStyle.fontSize),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: textStyle.fontSize),
          const SizedBox(width: 8),
          child,
        ],
      );
    }

    if (iconRight != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(width: 8),
          Icon(iconRight, size: textStyle.fontSize),
        ],
      );
    }

    return child;
  }
}

/// shadcn-ui 风格的图标按钮
class ShadcnIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final ShadcnButtonVariant variant;
  final double? size;
  final bool disabled;

  const ShadcnIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = ShadcnButtonVariant.ghost,
    this.size,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return ShadcnButton(
      onPressed: onPressed,
      variant: variant,
      size: ShadcnButtonSize.icon,
      disabled: disabled,
      child: Icon(icon, size: size ?? 20),
    );
  }
}