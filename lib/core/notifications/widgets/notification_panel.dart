import 'package:flutter/material.dart';
import '../notification_model.dart';
import '../notification_manager.dart';
import 'notification_item.dart';
import '../../theme/shard_theme.dart';

class NotificationPanel extends StatefulWidget {
  final VoidCallback onClose;
  final GlobalKey notificationButtonKey;

  const NotificationPanel({
    super.key,
    required this.onClose,
    required this.notificationButtonKey,
  });

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _slideYAnimation;

  Offset _panelPosition = Offset.zero;
  Size _panelSize = Size.zero;
  bool _positioned = false;

  @override
  void initState() {
    super.initState();
    NotificationManager.instance.addListener(_onNotificationsChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initAnimations();
      _calculatePosition();
      _animationController.forward();
    });
  }

  void _initAnimations() {
    final theme = Theme.of(context);
    final factor =
        theme.extension<ShardThemeExtension>()?.animationDurationFactor ?? 1.0;
    final duration = (250 * factor).round();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: duration),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideYAnimation = Tween<double>(begin: -8.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    NotificationManager.instance.removeListener(_onNotificationsChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onNotificationsChanged() {
    if (mounted) setState(() {});
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      if (mounted) widget.onClose();
    });
  }

  void _calculatePosition() {
    if (!mounted) return;

    final RenderBox? buttonBox =
        widget.notificationButtonKey.currentContext?.findRenderObject()
            as RenderBox?;
    final RenderBox? overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox?;

    if (buttonBox == null || overlayBox == null || !buttonBox.attached) return;

    final buttonPosition = buttonBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );
    final buttonSize = buttonBox.size;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const panelWidth = 360.0;
    const panelMaxHeight = 450.0;

    double left = buttonPosition.dx + buttonSize.width - panelWidth - 16;
    if (left < 16) left = 16;
    if (left + panelWidth > screenWidth - 16) {
      left = screenWidth - panelWidth - 16;
    }

    final topPosition = buttonPosition.dy - panelMaxHeight - 8;
    double top;
    double panelHeight;

    if (topPosition < 60) {
      top = buttonPosition.dy + buttonSize.height + 8;
      panelHeight = (screenHeight - top - 16).clamp(200.0, panelMaxHeight);
    } else {
      top = topPosition;
      panelHeight = panelMaxHeight;
    }

    setState(() {
      _panelPosition = Offset(left, top);
      _panelSize = Size(panelWidth, panelHeight);
      _positioned = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_positioned) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();
    final notifications = NotificationManager.instance.notifications;

    return GestureDetector(
      onTap: _dismiss,
      behavior: HitTestBehavior.translucent,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned(
              left: _panelPosition.dx,
              top: _panelPosition.dy,
              width: _panelSize.width,
              height: _panelSize.height,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideYAnimation.value),
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      alignment: Alignment.topCenter,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: child,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(
                      themeExtension?.cardBorderRadius ?? 8.0,
                    ),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      themeExtension?.cardBorderRadius ?? 8.0,
                    ),
                    child: Column(
                      children: [
                        _buildHeader(context, colorScheme),
                        const Divider(height: 1),
                        Flexible(
                          child: notifications.isEmpty
                              ? _buildEmptyState(context, colorScheme)
                              : _buildNotificationList(context, notifications),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    final notifications = NotificationManager.instance.notifications;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.notifications_outlined,
              size: 18,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '通知中心',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (notifications.isNotEmpty)
                  Text(
                    '${notifications.length} 条通知',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (notifications.isNotEmpty)
            GestureDetector(
              onTap: () => NotificationManager.clearAll(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.delete_sweep_outlined,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '清除',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 12),
          Text(
            '暂无通知',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '新的通知将在这里显示',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    List<AppNotification> notifications,
  ) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: notifications.map((notification) {
        return NotificationItemWidget(
          key: ValueKey(notification.id),
          notification: notification,
          onDismiss: () => NotificationManager.dismiss(notification.id),
        );
      }).toList(),
    );
  }
}
