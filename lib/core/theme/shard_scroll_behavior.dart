// ShardXL 自定义滚动行为
// lib/core/theme/shard_scroll_behavior.dart
// 提供更流畅丝滑的滚动体验

import 'dart:ui';
import 'package:flutter/material.dart';

/// 自定义滚动行为，提供更流畅的滚动体验
class ShardScrollBehavior extends ScrollBehavior {
  const ShardScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // 使用更平滑的滚动物理效果
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // 使用自定义的滚动条样式
    return Scrollbar(
      controller: details.controller,
      thumbVisibility: false,
      trackVisibility: false,
      interactive: true,
      radius: const Radius.circular(8),
      thickness: 6,
      child: child,
    );
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // 使用发光效果的过度滚动指示器（类似 iOS 风格）
    return GlowingOverscrollIndicator(
      axisDirection: details.direction,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      child: child,
    );
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}

/// 带有平滑动画的滚动控制器扩展
extension SmoothScrollController on ScrollController {
  /// 平滑滚动到指定位置
  Future<void> smoothScrollTo(
    double offset, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
  }) async {
    await animateTo(
      offset.clamp(0.0, position.maxScrollExtent),
      duration: duration,
      curve: curve,
    );
  }

  /// 平滑滚动到顶部
  Future<void> smoothScrollToTop({
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutCubic,
  }) async {
    await smoothScrollTo(0, duration: duration, curve: curve);
  }

  /// 平滑滚动到底部
  Future<void> smoothScrollToBottom({
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutCubic,
  }) async {
    await smoothScrollTo(
      position.maxScrollExtent,
      duration: duration,
      curve: curve,
    );
  }
}
