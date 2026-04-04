import 'package:flutter/material.dart';
import '../../widgets/shadcn_components.dart';
import '../notification_model.dart';
import '../../theme/shard_theme.dart';

class NotificationItemWidget extends StatefulWidget {
  final AppNotification notification;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;

  const NotificationItemWidget({
    super.key,
    required this.notification,
    this.onDismiss,
    this.onTap,
  });

  @override
  State<NotificationItemWidget> createState() => _NotificationItemWidgetState();
}

class _NotificationItemWidgetState extends State<NotificationItemWidget>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  bool _isDismissing = false;
  AnimationController? _snapBackController;

  late AnimationController _dismissAnimationController;
  late Animation<double> _dismissHeightAnimation;
  late Animation<double> _dismissOpacityAnimation;
  late Animation<double> _dismissSlideAnimation;

  static const double _dismissThreshold = 80.0;

  @override
  void initState() {
    super.initState();
    _dismissAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _dismissHeightAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _dismissAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOutCubic),
      ),
    );
    _dismissOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _dismissAnimationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _dismissSlideAnimation = Tween<double>(begin: 0.0, end: 60.0).animate(
      CurvedAnimation(
        parent: _dismissAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInCubic),
      ),
    );
  }

  @override
  void dispose() {
    _dismissAnimationController.dispose();
    _snapBackController?.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_isDismissing) return;
    if (details.delta.dx < 0) {
      setState(() {
        _dragOffset += details.delta.dx;
        _dragOffset = _dragOffset.clamp(-300.0, 0.0);
      });
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_isDismissing) return;

    final velocityThreshold = 500.0;

    if (_dragOffset.abs() > _dismissThreshold ||
        details.velocity.pixelsPerSecond.dx.abs() > velocityThreshold) {
      _performDismiss();
    } else {
      _snapBack();
    }
  }

  void _snapBack() {
    if (_dragOffset == 0) return;
    _snapBackController?.dispose();

    final startOffset = _dragOffset;
    _snapBackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    final animation = CurvedAnimation(
      parent: _snapBackController!,
      curve: Curves.easeOutCubic,
    );

    animation.addListener(() {
      if (mounted) {
        setState(() {
          _dragOffset = startOffset * (1 - animation.value);
        });
      }
    });

    _snapBackController!.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        if (mounted) {
          _snapBackController?.dispose();
          _snapBackController = null;
        }
      }
    });

    _snapBackController!.forward();
  }

  void _performDismiss() {
    setState(() {
      _isDismissing = true;
    });

    _dismissAnimationController.forward().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();
    final cardRadius = themeExtension?.cardBorderRadius ?? 8.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardRadius),
        child: Stack(
          children: [
            _buildDismissBackground(),
            GestureDetector(
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              behavior: HitTestBehavior.opaque,
              child: _isDismissing
                  ? ListenableBuilder(
                      listenable: _dismissAnimationController,
                      builder: (context, child) {
                        final heightFactor = _dismissHeightAnimation.value;
                        final slideOffset = _dismissSlideAnimation.value;
                        return ClipRect(
                          child: Align(
                            heightFactor: heightFactor.clamp(0.001, 1.0),
                            child: Transform.translate(
                              offset: Offset(-slideOffset, 0),
                              child: Opacity(
                                opacity: _dismissOpacityAnimation.value,
                                child: child,
                              ),
                            ),
                          ),
                        );
                      },
                      child: _buildContent(context),
                    )
                  : Transform.translate(
                      offset: Offset(_dragOffset, 0),
                      child: _buildContent(context),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    final colorScheme = Theme.of(context).colorScheme;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(
          themeExtension?.cardBorderRadius ?? 8.0,
        ),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 16),
      child: Icon(
        Icons.delete_outline,
        color: colorScheme.error.withValues(alpha: 0.8),
        size: 20,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();

    Color iconBgColor = colorScheme.primary.withValues(alpha: 0.1);
    Color iconColor = colorScheme.primary;
    IconData iconData = Icons.notifications_outlined;

    switch (widget.notification.type) {
      case NotificationType.temporary:
      case NotificationType.normal:
        break;
      case NotificationType.progress:
        break;
      case NotificationType.warning:
        iconBgColor = Colors.orange.withValues(alpha: 0.1);
        iconColor = Colors.orange;
        iconData = Icons.warning_amber_outlined;
        break;
      case NotificationType.error:
        iconBgColor = colorScheme.error.withValues(alpha: 0.1);
        iconColor = colorScheme.error;
        iconData = Icons.error_outline;
        break;
    }

    final effectiveOnTap =
        widget.onTap ??
        (widget.notification.isClickable
            ? (widget.notification.onClick ??
                  () {
                    _showNotificationDetailDialog(context, widget.notification);
                  })
            : null);

    return GestureDetector(
      onTap: effectiveOnTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.zero,
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    children: [
                      Text(
                        widget.notification.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.notification.message,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(widget.notification.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.notification.type == NotificationType.progress &&
                widget.notification.progress != null) ...[
              const SizedBox(height: 8),
              ShadcnProgress(value: widget.notification.progress!, height: 6),
              const SizedBox(height: 4),
              Text(
                '${(widget.notification.progress! * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) {
      return '刚刚';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else {
      return '${timestamp.month}/${timestamp.day} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showNotificationDetailDialog(
    BuildContext context,
    AppNotification notification,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        notification.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('关闭'),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    notification.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '时间: ${notification.timestamp.toString().substring(0, 19)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  if (notification.type == NotificationType.progress &&
                      notification.progress != null) ...[
                    const SizedBox(height: 12),
                    ShadcnProgress(value: notification.progress!),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
