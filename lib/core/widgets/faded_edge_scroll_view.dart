// ShardXL 羽化边缘滚动视图组件
// lib/core/widgets/faded_edge_scroll_view.dart
//
// 在滚动视图的顶部和底部添加透明度羽化效果
// 符合 shadcn-ui 设计风格

import 'package:flutter/material.dart';

/// 羽化边缘滚动视图
/// 在滚动内容的顶部和底部添加透明度渐变效果
class FadedEdgeScrollView extends StatefulWidget {
  final Widget child;
  final double fadeHeight;
  final bool enableTopFade;
  final bool enableBottomFade;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;

  const FadedEdgeScrollView({
    super.key,
    required this.child,
    this.fadeHeight = 32,
    this.enableTopFade = true,
    this.enableBottomFade = true,
    this.padding,
    this.controller,
  });

  @override
  State<FadedEdgeScrollView> createState() => _FadedEdgeScrollViewState();
}

class _FadedEdgeScrollViewState extends State<FadedEdgeScrollView> {
  late ScrollController _scrollController;
  bool _showTopFade = false;
  bool _showBottomFade = true;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFadeVisibility();
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    _updateFadeVisibility();
  }

  void _updateFadeVisibility() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    final canScrollUp = currentScroll > 0;
    final canScrollDown = currentScroll < maxScroll;

    if (_showTopFade != canScrollUp || _showBottomFade != canScrollDown) {
      setState(() {
        _showTopFade = canScrollUp;
        _showBottomFade = canScrollDown;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget scrollView = widget.child;

    if (widget.child is! SingleChildScrollView) {
      scrollView = SingleChildScrollView(
        controller: _scrollController,
        padding: widget.padding,
        child: widget.child,
      );
    }

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            if (widget.enableTopFade && _showTopFade) Colors.transparent else Colors.white,
            Colors.white,
            Colors.white,
            if (widget.enableBottomFade && _showBottomFade) Colors.transparent else Colors.white,
          ],
          stops: [
            0.0,
            widget.enableTopFade && _showTopFade ? (widget.fadeHeight / bounds.height).clamp(0.0, 0.15) : 0.0,
            widget.enableBottomFade && _showBottomFade ? (1.0 - widget.fadeHeight / bounds.height).clamp(0.85, 1.0) : 1.0,
            1.0,
          ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: scrollView,
    );
  }
}

/// 羽化边缘包装器（通用版）
/// 用于包装滚动视图（GridView、ListView、SingleChildScrollView 等）
/// 使用 NotificationListener 监听滚动，无需依赖 ScrollController
class FadedEdgeWrapper extends StatefulWidget {
  final Widget scrollView;
  final double fadeHeight;
  final bool enableTopFade;
  final bool enableBottomFade;

  const FadedEdgeWrapper({
    super.key,
    required this.scrollView,
    this.fadeHeight = 32,
    this.enableTopFade = true,
    this.enableBottomFade = true,
  });

  @override
  State<FadedEdgeWrapper> createState() => _FadedEdgeWrapperState();
}

class _FadedEdgeWrapperState extends State<FadedEdgeWrapper> {
  bool _showTopFade = false;
  bool _showBottomFade = true;
  double _lastPixels = 0;
  double _lastMaxExtent = 0;

  void _updateFadeFromNotification(ScrollNotification notification) {
    final metrics = notification.metrics;

    final canScrollUp = metrics.pixels > 0;
    final canScrollDown = metrics.pixels < metrics.maxScrollExtent;

    if (_showTopFade != canScrollUp || _showBottomFade != canScrollDown ||
        _lastPixels != metrics.pixels || _lastMaxExtent != metrics.maxScrollExtent) {
      setState(() {
        _showTopFade = canScrollUp;
        _showBottomFade = canScrollDown;
        _lastPixels = metrics.pixels;
        _lastMaxExtent = metrics.maxScrollExtent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _updateFadeFromNotification(notification);
        return false;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ShaderMask(
            shaderCallback: (Rect bounds) {
              final topFadeStop = (widget.fadeHeight / bounds.height).clamp(0.0, 0.12);
              final bottomFadeStart = (1.0 - widget.fadeHeight / bounds.height).clamp(0.88, 1.0);

              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  if (widget.enableTopFade && _showTopFade) Colors.transparent else Colors.white,
                  Colors.white,
                  Colors.white,
                  if (widget.enableBottomFade && _showBottomFade) Colors.transparent else Colors.white,
                ],
                stops: [
                  0.0,
                  widget.enableTopFade && _showTopFade ? topFadeStop : 0.0,
                  widget.enableBottomFade && _showBottomFade ? bottomFadeStart : 1.0,
                  1.0,
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: widget.scrollView,
          );
        },
      ),
    );
  }
}
