// ShardXL 羽化边缘滚动视图组件
// lib/core/widgets/faded_edge_scroll_view.dart
//
// 提供滚动视图的羽化边缘效果
// 使用 ShaderMask 实现内容边缘透明渐变
// 注意：需要在 BackdropFilter 外部使用，否则会阻断毛玻璃效果

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

    return _FadedEdgeContainer(
      fadeHeight: widget.fadeHeight,
      showTopFade: widget.enableTopFade && _showTopFade,
      showBottomFade: widget.enableBottomFade && _showBottomFade,
      child: scrollView,
    );
  }
}

/// 羽化边缘容器
/// 使用 ShaderMask + BlendMode.dstIn 实现内容边缘透明渐变
class _FadedEdgeContainer extends StatelessWidget {
  final Widget child;
  final double fadeHeight;
  final bool showTopFade;
  final bool showBottomFade;

  const _FadedEdgeContainer({
    required this.child,
    required this.fadeHeight,
    required this.showTopFade,
    required this.showBottomFade,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        if (height.isInfinite || height <= 0) {
          return child;
        }

        final double topStop = showTopFade ? (fadeHeight / height).clamp(0.0, 0.5) : 0.0;
        final double bottomStop = showBottomFade
            ? (1.0 - fadeHeight / height).clamp(0.5, 1.0)
            : 1.0;

        return ShaderMask(
          shaderCallback: (Rect bounds) {
            if (showTopFade && showBottomFade) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: const [
                  Color(0x00000000),
                  Color(0xFF000000),
                  Color(0xFF000000),
                  Color(0x00000000),
                ],
                stops: [
                  0.0,
                  topStop,
                  bottomStop,
                  1.0,
                ],
              ).createShader(bounds);
            } else if (showTopFade) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: const [
                  Color(0x00000000),
                  Color(0xFF000000),
                ],
                stops: [
                  0.0,
                  topStop,
                ],
              ).createShader(bounds);
            } else if (showBottomFade) {
              return LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: const [
                  Color(0x00000000),
                  Color(0xFF000000),
                ],
                stops: [
                  0.0,
                  1.0 - bottomStop,
                ],
              ).createShader(bounds);
            } else {
              return LinearGradient(
                colors: const [Color(0xFF000000), Color(0xFF000000)],
              ).createShader(bounds);
            }
          },
          blendMode: BlendMode.dstIn,
          child: child,
        );
      },
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

  void _updateFadeFromNotification(ScrollNotification notification) {
    final metrics = notification.metrics;

    final canScrollUp = metrics.pixels > 0;
    final canScrollDown = metrics.pixels < metrics.maxScrollExtent;

    if (_showTopFade != canScrollUp || _showBottomFade != canScrollDown) {
      setState(() {
        _showTopFade = canScrollUp;
        _showBottomFade = canScrollDown;
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
          final height = constraints.maxHeight;
          if (height.isInfinite || height <= 0) {
            return widget.scrollView;
          }

          final double topStop = widget.enableTopFade && _showTopFade
              ? (widget.fadeHeight / height).clamp(0.0, 0.5)
              : 0.0;
          final double bottomStop = widget.enableBottomFade && _showBottomFade
              ? (1.0 - widget.fadeHeight / height).clamp(0.5, 1.0)
              : 1.0;

          return ShaderMask(
            shaderCallback: (Rect bounds) {
              if (widget.enableTopFade && _showTopFade && widget.enableBottomFade && _showBottomFade) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: const [
                    Color(0x00000000),
                    Color(0xFF000000),
                    Color(0xFF000000),
                    Color(0x00000000),
                  ],
                  stops: [
                    0.0,
                    topStop,
                    bottomStop,
                    1.0,
                  ],
                ).createShader(bounds);
              } else if (widget.enableTopFade && _showTopFade) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: const [
                    Color(0x00000000),
                    Color(0xFF000000),
                  ],
                  stops: [
                    0.0,
                    topStop,
                  ],
                ).createShader(bounds);
              } else if (widget.enableBottomFade && _showBottomFade) {
                return LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: const [
                    Color(0x00000000),
                    Color(0xFF000000),
                  ],
                  stops: [
                    0.0,
                    1.0 - bottomStop,
                  ],
                ).createShader(bounds);
              } else {
                return LinearGradient(
                  colors: const [Color(0xFF000000), Color(0xFF000000)],
                ).createShader(bounds);
              }
            },
            blendMode: BlendMode.dstIn,
            child: widget.scrollView,
          );
        },
      ),
    );
  }
}
