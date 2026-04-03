// ShardXL 可复用底部导航栏组件
// lib/core/widgets/shard_bottom_nav_bar.dart
//
// 包含两个组件：
// - ShardBottomNavBar: 主底部导航栏
// - ShardFloatingBottomNavBar: 悬浮底部导航栏（包裹 ShardBottomNavBar）

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/shard_theme.dart';
import '../../features/settings/providers/theme_provider.dart';

// ========================
// 尺寸测量组件
// ========================

/// 用于测量子组件尺寸的 Widget
typedef OnWidgetSizeChange = void Function(Size size);

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    super.key,
    required this.onChange,
    required Widget super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }

  @override
  void updateRenderObject(BuildContext context, MeasureSizeRenderObject renderObject) {
    renderObject.onChange = onChange;
  }
}

class MeasureSizeRenderObject extends RenderProxyBox {
  OnWidgetSizeChange onChange;
  Size? _previousSize;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();
    Size newSize = child?.size ?? Size.zero;
    if (_previousSize != newSize) {
      _previousSize = newSize;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onChange(newSize);
      });
    }
  }
}

// ========================
// 导航项数据模型
// ========================

/// 底部导航栏的单项配置
class NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

// ========================
// 主底部导航栏
// ========================

/// 可复用的底部导航栏
/// - 左对齐文本标签
/// - surfaceContainerHighest 背景
/// - 指示器背景移动动画 + 动态伸缩（距离越长拉伸越大）
class ShardBottomNavBar extends ConsumerStatefulWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool showTopBorder;

  const ShardBottomNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    this.showTopBorder = true,
  });

  @override
  ConsumerState<ShardBottomNavBar> createState() => _ShardBottomNavBarState();
}

class _ShardBottomNavBarState extends ConsumerState<ShardBottomNavBar>
    with TickerProviderStateMixin {
  // 动画控制器：位置动画
  late AnimationController _posController;
  late Animation<double> _posAnimation;

  // 动画控制器：伸缩动画
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  // 指示器状态
  int _fromIndex = 0;
  int _toIndex = 0;

  // 需要 dispose 的动画资源
  final List<dynamic> _disposables = [];

  @override
  void initState() {
    super.initState();
    _posController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _posAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _posController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
    _disposables.addAll([_posController, _scaleController]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 布局变化时重新定位指示器
    _fromIndex = widget.selectedIndex;
    _toIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant ShardBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _animateToIndex(oldWidget.selectedIndex, widget.selectedIndex);
    }
  }

  /// 触发指示器从 fromIndex 移动到 toIndex 的动画
  void _animateToIndex(int from, int to) {
    // 根据动画速率调整时长
    final theme = Theme.of(context);
    final factor = theme.extension<ShardThemeExtension>()
            ?.animationDurationFactor ??
        1.0;

    _fromIndex = from;
    _toIndex = to;

    // 重置动画控制器
    _posController.reset();
    _scaleController.reset();

    // 位置动画时长：根据距离 + 速率因子
    final posDuration = (300 * factor).round();
    _posController.duration = Duration(milliseconds: posDuration);

    // 伸缩动画时长：短暂回弹
    final scaleDuration = (200 * factor).round();
    _scaleController.duration = Duration(milliseconds: scaleDuration);

    // 同时启动位置和伸缩动画
    _posController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    for (final d in _disposables) {
      if (d is AnimationController) d.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final themeState = ref.watch(shardThemeProvider);
    final enableGlass = themeState.theme.enableGlassEffect;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();
    final blurSigma = themeExtension?.glassBlurSigma ?? 16.0;

    final navBarContent = Container(
      padding: EdgeInsets.fromLTRB(12, 28, 12, 8 + bottomPadding),
      decoration: BoxDecoration(
        color: enableGlass
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.8)
            : colorScheme.surfaceContainerHighest,
        border: widget.showTopBorder
            ? Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const itemWidth = 120.0;
          const itemPadding = 8.0;

          return Stack(
            children: [
              Positioned(
                left: 0,
                top: 10,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_posAnimation, _scaleAnimation]),
                  builder: (context, _) {
                    final pos = _posAnimation.value;
                    final scale = _scaleAnimation.value;

                    final center =
                        (_fromIndex + (_toIndex - _fromIndex) * pos) *
                                itemWidth +
                            itemWidth / 2;

                    final indicatorWidth = (itemWidth - itemPadding * 2) * scale;
                    final indicatorLeft = center - indicatorWidth / 2;

                    return Container(
                      width: indicatorWidth,
                      height: 30,
                      margin: EdgeInsets.only(left: indicatorLeft),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(widget.items.length, (index) {
                  return _buildNavItem(index, itemWidth);
                }),
              ),
            ],
          );
        },
      ),
    );

    return ClipPath(
      clipper: _InvertedRoundedClipper(),
      child: enableGlass
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: navBarContent,
            )
          : navBarContent,
    );
  }

  /// 构建单个导航项
  Widget _buildNavItem(int index, double itemWidth) {
    final isSelected = index == widget.selectedIndex;
    final colorScheme = Theme.of(context).colorScheme;
    final item = widget.items[index];

    return GestureDetector(
      onTap: () => widget.onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
          width: itemWidth,
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? item.selectedIcon : item.icon,
                size: 20,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
    );
  }
}

/// 向内凹的圆角裁剪器
/// 在顶部镂空一个占满整个宽度的圆角矩形凹槽（类似 QuickShell 效果）
class _InvertedRoundedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final notchHeight = 28.0; // 凹槽深度
    final notchRadius = 24.0; // 凹槽圆角半径

    // 从左上角开始
    path.moveTo(0, 0);

    // 凹槽左侧曲线（向下进入凹槽）
    // 控制点在左上，终点在左下
    path.quadraticBezierTo(
      0, notchHeight, // 控制点：向下
      notchRadius, notchHeight, // 终点：向右
    );

    // 凹槽底部直线（占满整个宽度）
    path.lineTo(size.width - notchRadius, notchHeight);

    // 凹槽右侧曲线（向上退出凹槽）
    // 控制点在右下，终点在右上
    path.quadraticBezierTo(
      size.width, notchHeight, // 控制点
      size.width, 0, // 终点：向上回到顶部
    );

    // 顶部右边直线
    path.lineTo(size.width, 0);

    // 右边向下
    path.lineTo(size.width, size.height);

    // 底边
    path.lineTo(0, size.height);

    // 闭合路径
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ========================
// 悬浮底部导航栏
// ========================

/// 悬浮风格的底部导航栏
/// 将 ShardBottomNavBar 包裹在浮动卡片中
/// 背景使用 surfaceContainerHighest + 可选毛玻璃效果
class ShardFloatingBottomNavBar extends ConsumerWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final double marginBottom;

  const ShardFloatingBottomNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    this.marginBottom = 12,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final themeState = ref.watch(shardThemeProvider);
    final enableGlass = themeState.theme.enableGlassEffect;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();
    final blurSigma = themeExtension?.glassBlurSigma ?? 16.0;

    final navBarCard = Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      color: enableGlass
          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.8)
          : colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicWidth(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: _ShardFloatingNavBarContent(
            items: items,
            selectedIndex: selectedIndex,
            onTap: onTap,
          ),
        ),
      ),
    );

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding + marginBottom),
      alignment: Alignment.center,
      child: enableGlass
          ? ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: navBarCard,
              ),
            )
          : navBarCard,
    );
  }
}

/// 悬浮导航栏内部内容 - 使用动态宽度
class _ShardFloatingNavBarContent extends StatefulWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _ShardFloatingNavBarContent({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<_ShardFloatingNavBarContent> createState() =>
      _ShardFloatingNavBarContentState();
}

class _ShardFloatingNavBarContentState
    extends State<_ShardFloatingNavBarContent>
    with TickerProviderStateMixin {
  late AnimationController _posController;
  late Animation<double> _posAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  int _fromIndex = 0;
  int _toIndex = 0;

  final List<dynamic> _disposables = [];

  // 导航项高度
  static const double _itemHeight = 40;

  // 存储每个导航项的宽度
  final Map<int, double> _itemWidths = {};
  final GlobalKey _rowKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _posController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _posAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _posController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
    _disposables.addAll([_posController, _scaleController]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fromIndex = widget.selectedIndex;
    _toIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant _ShardFloatingNavBarContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _animateToIndex(oldWidget.selectedIndex, widget.selectedIndex);
    }
  }

  void _animateToIndex(int from, int to) {
    final theme = Theme.of(context);
    final factor = theme.extension<ShardThemeExtension>()
            ?.animationDurationFactor ??
        1.0;

    _fromIndex = from;
    _toIndex = to;

    _posController.reset();
    _scaleController.reset();

    final posDuration = (300 * factor).round();
    _posController.duration = Duration(milliseconds: posDuration);

    final scaleDuration = (200 * factor).round();
    _scaleController.duration = Duration(milliseconds: scaleDuration);

    _posController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    for (final d in _disposables) {
      if (d is AnimationController) d.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: _itemHeight,
      child: Stack(
        children: [
          // 指示器层 - 完全圆角，宽度根据元素动态变化
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: Listenable.merge([_posAnimation, _scaleAnimation]),
              builder: (context, _) {
                final pos = _posAnimation.value;
                final scale = _scaleAnimation.value;

                // 计算当前指示器的位置和宽度
                final fromWidth = _itemWidths[_fromIndex] ?? 80;
                final toWidth = _itemWidths[_toIndex] ?? 80;
                final currentWidth = fromWidth + (toWidth - fromWidth) * pos;

                // 计算左侧位置（累加前面所有项的宽度）
                double fromLeft = 0;
                double toLeft = 0;
                for (int i = 0; i < _fromIndex; i++) {
                  fromLeft += _itemWidths[i] ?? 80;
                }
                for (int i = 0; i < _toIndex; i++) {
                  toLeft += _itemWidths[i] ?? 80;
                }
                final currentLeft = fromLeft + (toLeft - fromLeft) * pos;

                final indicatorWidth = currentWidth * scale;
                final indicatorLeft = currentLeft + (currentWidth - indicatorWidth) / 2;

                return Container(
                  width: indicatorWidth,
                  height: _itemHeight,
                  margin: EdgeInsets.only(left: indicatorLeft),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              },
            ),
          ),
          // 导航项层
          Row(
            key: _rowKey,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.items.length, (index) {
              return _buildNavItem(index);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = index == widget.selectedIndex;
    final colorScheme = Theme.of(context).colorScheme;
    final item = widget.items[index];

    return GestureDetector(
      onTap: () => widget.onTap(index),
      behavior: HitTestBehavior.opaque,
      child: MeasureSize(
        onChange: (size) {
          if (size.width > 0 && _itemWidths[index] != size.width) {
            setState(() {
              _itemWidths[index] = size.width;
            });
          }
        },
        child: IntrinsicWidth(
          child: Container(
            height: _itemHeight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  size: 16,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
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
