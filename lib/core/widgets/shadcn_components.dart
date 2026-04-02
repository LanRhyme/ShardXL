// ShardXL shadcn-ui 风格组件库
// lib/core/widgets/shadcn_components.dart

import 'package:flutter/material.dart';
import '../theme/shard_theme.dart';

// ========================
// shadcn-ui 风格的 Badge
// ========================

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
    final borderRadius = BorderRadius.circular(themeExtension?.buttonBorderRadius ?? 10.0);

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (variant) {
      case ShadcnBadgeVariant.default_:
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        break;
      case ShadcnBadgeVariant.secondary:
        backgroundColor = colorScheme.secondary;
        foregroundColor = colorScheme.onSecondary;
        break;
      case ShadcnBadgeVariant.destructive:
        backgroundColor = colorScheme.error;
        foregroundColor = colorScheme.onError;
        break;
      case ShadcnBadgeVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = colorScheme.onSurface;
        borderSide = BorderSide(color: colorScheme.outline);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
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
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ========================
// shadcn-ui 风格的 Input
// ========================

class ShadcnInput extends StatelessWidget {
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;

  const ShadcnInput({
    super.key,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();
    final borderRadius = BorderRadius.circular(themeExtension?.inputBorderRadius ?? 10.0);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: placeholder,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 18, color: colorScheme.onSurfaceVariant)
            : null,
        suffixIcon: suffix,
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
      ),
    );
  }
}

// ========================
// shadcn-ui 风格的 Separator
// ========================

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

    return Container(
      height: horizontal ? (height ?? 1) : null,
      width: !horizontal ? (width ?? 1) : null,
      color: colorScheme.outline.withValues(alpha: 0.2),
    );
  }
}

// ========================
// shadcn-ui 风格的 Avatar
// ========================

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

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: imageUrl != null
            ? ClipOval(
                child: Image.network(
                  imageUrl!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildInitials(colorScheme),
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
        fontSize: size * 0.4,
        fontWeight: FontWeight.w600,
        color: colorScheme.primary,
      ),
    );
  }
}

// ========================
// shadcn-ui 风格的 Skeleton
// ========================

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
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
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
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: _animation.value),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}

// ========================
// shadcn-ui 风格的 Tabs
// ========================

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
    final borderRadius = BorderRadius.circular(themeExtension?.buttonBorderRadius ?? 10.0);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: borderRadius,
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
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
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
                            ? colorScheme.primary
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

// ========================
// shadcn-ui 风格的 Alert
// ========================

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
    final borderRadius = BorderRadius.circular(themeExtension?.cardBorderRadius ?? 10.0);

    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    IconData effectiveIcon;

    switch (variant) {
      case ShadcnAlertVariant.default_:
        backgroundColor = colorScheme.surface;
        borderColor = colorScheme.outline;
        iconColor = colorScheme.primary;
        effectiveIcon = icon ?? Icons.info_outline;
        break;
      case ShadcnAlertVariant.destructive:
        backgroundColor = colorScheme.errorContainer.withValues(alpha: 0.1);
        borderColor = colorScheme.error;
        iconColor = colorScheme.error;
        effectiveIcon = icon ?? Icons.error_outline;
        break;
      case ShadcnAlertVariant.success:
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        borderColor = Colors.green;
        iconColor = Colors.green;
        effectiveIcon = icon ?? Icons.check_circle_outline;
        break;
      case ShadcnAlertVariant.warning:
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        borderColor = Colors.orange;
        iconColor = Colors.orange;
        effectiveIcon = icon ?? Icons.warning_amber_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor.withValues(alpha: 0.3)),
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
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onClose != null)
            GestureDetector(
              onTap: onClose,
              child: Icon(Icons.close, size: 16, color: colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}

// ========================
// shadcn-ui 风格的 Progress
// ========================

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
    final borderRadius = BorderRadius.circular(themeExtension?.buttonBorderRadius ?? 10.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius,
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: valueColor ?? colorScheme.primary,
            borderRadius: borderRadius,
          ),
        ),
      ),
    );
  }
}