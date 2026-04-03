// ShardXL shadcn-ui 风格组件库
// lib/core/widgets/shadcn_components.dart

import 'package:flutter/material.dart';
import '../theme/shard_theme.dart';

enum ShadcnBadgeVariant { default_, secondary, destructive, outline }

class ShadcnBadge extends StatelessWidget {
  final String text;
  final ShadcnBadgeVariant variant;
  final IconData? icon;

  const ShadcnBadge({
    super.key,
    required this.text,
    this.variant = ShadcnBadgeVariant.default_,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();
    final borderRadius = themeExtension?.buttonBorderRadius ?? 6.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (variant) {
      case ShadcnBadgeVariant.default_:
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        break;
      case ShadcnBadgeVariant.secondary:
        backgroundColor = isDark
            ? colorScheme.onSurface.withValues(alpha: 0.12)
            : colorScheme.onSurface.withValues(alpha: 0.08);
        foregroundColor = colorScheme.onSurface;
        break;
      case ShadcnBadgeVariant.destructive:
        backgroundColor = colorScheme.error;
        foregroundColor = colorScheme.onError;
        break;
      case ShadcnBadgeVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = colorScheme.onSurface;
        borderSide = BorderSide(
          color: colorScheme.outline.withValues(alpha: isDark ? 0.3 : 0.5),
          width: 1,
        );
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderSide != null ? Border.fromBorderSide(borderSide) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foregroundColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: foregroundColor,
              letterSpacing: 0.0,
            ),
          ),
        ],
      ),
    );
  }
}

class ShadcnInput extends StatefulWidget {
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final int? maxLines;
  final ValueChanged<String>? onSubmitted;

  const ShadcnInput({
    super.key,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.maxLines = 1,
    this.onSubmitted,
  });

  @override
  State<ShadcnInput> createState() => _ShadcnInputState();
}

class _ShadcnInputState extends State<ShadcnInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();
    final borderRadius = themeExtension?.inputBorderRadius ?? 6.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = _isFocused
        ? colorScheme.primary
        : colorScheme.outline.withValues(alpha: isDark ? 0.25 : 0.4);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  blurRadius: 0,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        obscureText: widget.obscureText,
        enabled: widget.enabled,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        onSubmitted: widget.onSubmitted,
        focusNode: _focusNode,
        style: TextStyle(
          fontSize: 14,
          color: widget.enabled
              ? colorScheme.onSurface
              : colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        decoration: InputDecoration(
          hintText: widget.placeholder,
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  size: 18,
                  color: _isFocused
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                )
              : null,
          suffixIcon: widget.suffix,
          filled: true,
          fillColor: isDark
              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : colorScheme.surface.withValues(alpha: 0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class ShadcnSeparator extends StatelessWidget {
  final bool horizontal;
  final double? height;
  final double? width;

  const ShadcnSeparator({
    super.key,
    this.horizontal = true,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: horizontal ? (height ?? 1) : null,
      width: !horizontal ? (width ?? 1) : null,
      color: colorScheme.outline.withValues(alpha: isDark ? 0.12 : 0.15),
    );
  }
}

class ShadcnAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double size;
  final Color? backgroundColor;

  const ShadcnAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 40,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ??
            colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: imageUrl != null
            ? ClipOval(
                child: Image.network(
                  imageUrl!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildInitials(colorScheme),
                ),
              )
            : _buildInitials(colorScheme),
      ),
    );
  }

  Widget _buildInitials(ColorScheme colorScheme) {
    return Text(
      initials ?? '?',
      style: TextStyle(
        fontSize: size * 0.38,
        fontWeight: FontWeight.w600,
        color: colorScheme.primary,
        letterSpacing: 0.0,
      ),
    );
  }
}

class ShadcnSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShadcnSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShadcnSkeleton> createState() => _ShadcnSkeletonState();
}

class _ShadcnSkeletonState extends State<ShadcnSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: 0.25, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: _animation.value * 0.08)
                : Colors.black.withValues(alpha: _animation.value * 0.06),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(6),
          ),
        );
      },
    );
  }
}

class ShadcnTabs extends StatelessWidget {
  final List<ShadcnTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const ShadcnTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();
    final borderRadius = themeExtension?.buttonBorderRadius ?? 6.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.onSurface.withValues(alpha: 0.06)
            : colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? colorScheme.surfaceContainerHigh
                          : colorScheme.surface)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(borderRadius - 2),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.15)
                                : Colors.black.withValues(alpha: 0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (tab.icon != null) ...[
                      Icon(
                        tab.icon,
                        size: 16,
                        color: isSelected
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                        color: isSelected
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ShadcnTab {
  final String label;
  final IconData? icon;

  const ShadcnTab({required this.label, this.icon});
}

enum ShadcnAlertVariant { default_, destructive, success, warning }

class ShadcnAlert extends StatelessWidget {
  final String title;
  final String? description;
  final ShadcnAlertVariant variant;
  final IconData? icon;
  final VoidCallback? onClose;

  const ShadcnAlert({
    super.key,
    required this.title,
    this.description,
    this.variant = ShadcnAlertVariant.default_,
    this.icon,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();
    final borderRadius = themeExtension?.cardBorderRadius ?? 6.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    IconData effectiveIcon;

    switch (variant) {
      case ShadcnAlertVariant.default_:
        backgroundColor = isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surface;
        borderColor = colorScheme.outline.withValues(alpha: 0.3);
        iconColor = colorScheme.primary;
        effectiveIcon = icon ?? Icons.info_outline;
        break;
      case ShadcnAlertVariant.destructive:
        backgroundColor = isDark
            ? colorScheme.errorContainer.withValues(alpha: 0.15)
            : colorScheme.errorContainer.withValues(alpha: 0.1);
        borderColor = colorScheme.error.withValues(alpha: 0.4);
        iconColor = colorScheme.error;
        effectiveIcon = icon ?? Icons.error_outline;
        break;
      case ShadcnAlertVariant.success:
        backgroundColor = isDark
            ? Colors.green.withValues(alpha: 0.08)
            : Colors.green.withValues(alpha: 0.05);
        borderColor = Colors.green.withValues(alpha: 0.4);
        iconColor = Colors.green;
        effectiveIcon = icon ?? Icons.check_circle_outline;
        break;
      case ShadcnAlertVariant.warning:
        backgroundColor = isDark
            ? Colors.orange.withValues(alpha: 0.08)
            : Colors.orange.withValues(alpha: 0.05);
        borderColor = Colors.orange.withValues(alpha: 0.4);
        iconColor = Colors.orange;
        effectiveIcon = icon ?? Icons.warning_amber_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(effectiveIcon, size: 18, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                    letterSpacing: 0.0,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onClose != null)
            GestureDetector(
              onTap: onClose,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ShadcnProgress extends StatelessWidget {
  final double value;
  final double height;
  final Color? backgroundColor;
  final Color? valueColor;

  const ShadcnProgress({
    super.key,
    required this.value,
    this.height = 8,
    this.backgroundColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();
    final borderRadius = themeExtension?.buttonBorderRadius ?? 6.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06)),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: valueColor ?? colorScheme.primary,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        ),
      ),
    );
  }
}

class ShadcnSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  const ShadcnSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: 44,
      height: 24,
      decoration: BoxDecoration(
        color: value
            ? colorScheme.primary
            : (isDark
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(12),
        border: !value
            ? Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
      ),
      child: GestureDetector(
        onTap: enabled && onChanged != null ? () => onChanged!(!value) : null,
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShadcnTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  final bool preferBelow;

  const ShadcnTooltip({
    super.key,
    required this.message,
    required this.child,
    this.preferBelow = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: message,
      preferBelow: preferBelow,
      verticalOffset: 10,
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      textStyle: TextStyle(
        fontSize: 12,
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w400,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: child,
    );
  }
}
