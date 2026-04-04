import 'package:flutter/material.dart';
import '../../widgets/shadcn_components.dart';
import '../notification_model.dart';
import '../notification_manager.dart';
import '../../theme/shard_theme.dart';

class NotificationPopup extends StatefulWidget {
  const NotificationPopup({super.key});

  @override
  State<NotificationPopup> createState() => _NotificationPopupState();
}

class _NotificationPopupState extends State<NotificationPopup> {
  @override
  void initState() {
    super.initState();
    NotificationManager.instance.addPopupListener(_onPopupsChanged);
  }

  @override
  void dispose() {
    NotificationManager.instance.removePopupListener(_onPopupsChanged);
    super.dispose();
  }

  void _onPopupsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final popups = NotificationManager.instance.popups;
    if (popups.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 48,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 340,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: popups.map((popup) {
              return _AnimatedNotificationCard(
                key: ValueKey(popup.id),
                notification: popup,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _AnimatedNotificationCard extends StatefulWidget {
  final AppNotification notification;

  const _AnimatedNotificationCard({super.key, required this.notification});

  @override
  State<_AnimatedNotificationCard> createState() =>
      _AnimatedNotificationCardState();
}

class _AnimatedNotificationCardState extends State<_AnimatedNotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  static const Duration _animationDuration = Duration(milliseconds: 2500);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _startEnterAnimation();
  }

  void _startEnterAnimation() {
    _controller.forward().then((_) {
      if (mounted) {
        _startExitAnimation();
      }
    });
  }

  void _startExitAnimation() {
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInBack));

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
      ),
    );

    _controller.forward(from: 0.0).then((_) {
      if (mounted) {
        NotificationManager.dismissPopup(widget.notification.id);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(360 * _slideAnimation.value, 0),
          child: Opacity(
            opacity: _opacityAnimation.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: _PopupCard(notification: widget.notification),
    );
  }
}

class _PopupCard extends StatelessWidget {
  final AppNotification notification;

  const _PopupCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color borderColor;
    Color iconBgColor;
    Color iconColor;
    IconData iconData;

    switch (notification.type) {
      case NotificationType.temporary:
      case NotificationType.normal:
        borderColor = colorScheme.outline.withValues(alpha: isDark ? 0.2 : 0.3);
        iconBgColor = colorScheme.primary.withValues(alpha: 0.1);
        iconColor = colorScheme.primary;
        iconData = Icons.notifications_outlined;
        break;
      case NotificationType.progress:
        borderColor = colorScheme.primary.withValues(alpha: 0.3);
        iconBgColor = colorScheme.primary.withValues(alpha: 0.1);
        iconColor = colorScheme.primary;
        iconData = Icons.downloading_outlined;
        break;
      case NotificationType.warning:
        borderColor = Colors.orange.withValues(alpha: 0.4);
        iconBgColor = Colors.orange.withValues(alpha: 0.1);
        iconColor = Colors.orange;
        iconData = Icons.warning_amber_outlined;
        break;
      case NotificationType.error:
        borderColor = colorScheme.error.withValues(alpha: 0.4);
        iconBgColor = colorScheme.error.withValues(alpha: 0.1);
        iconColor = colorScheme.error;
        iconData = Icons.error_outline;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(
          themeExtension?.cardBorderRadius ?? 8.0,
        ),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: notification.isClickable
              ? (notification.onClick ??
                    () {
                      NotificationManager.dismissPopup(notification.id);
                    })
              : null,
          borderRadius: BorderRadius.circular(
            themeExtension?.cardBorderRadius ?? 8.0,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(
                      themeExtension?.buttonBorderRadius ?? 8.0,
                    ),
                  ),
                  child: Icon(iconData, size: 18, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        notification.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (notification.message.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          notification.message,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (notification.type == NotificationType.progress &&
                          notification.progress != null) ...[
                        const SizedBox(height: 6),
                        ShadcnProgress(
                          value: notification.progress!,
                          height: 4,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => NotificationManager.dismiss(notification.id),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
