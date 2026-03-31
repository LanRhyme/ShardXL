// ShardXL 可复用底部导航栏组件
// lib/core/widgets/shard_bottom_nav_bar.dart
//
// 包含两个组件：
// - ShardBottomNavBar: 主底部导航栏
// - ShardFloatingBottomNavBar: 悬浮底部导航栏（包裹 ShardBottomNavBar）

import 'package:flutter/material.dart';

import '../theme/shard_theme.dart';

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
class ShardBottomNavBar extends StatefulWidget {
  /// 导航项列表
  final List<NavItem> items;

  /// 当前选中索引
  final int selectedIndex;

  /// 选中回调
  final ValueChanged<int> onTap;

  /// 是否显示顶部边框（默认 true）
  final bool showTopBorder;

  const ShardBottomNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    this.showTopBorder = true,
  });

  @override
  State<ShardBottomNavBar> createState() => _ShardBottomNavBarState();
}

class _ShardBottomNavBarState extends State<ShardBottomNavBar>
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

    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottomPadding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
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
          final itemWidth = constraints.maxWidth / widget.items.length;
          final padding = itemWidth * 0.2;

          return Stack(
            children: [
              // 指示器层
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_posAnimation, _scaleAnimation]),
                  builder: (context, _) {
                    final pos = _posAnimation.value;
                    final scale = _scaleAnimation.value;

                    // 计算当前指示器中心位置
                    final center =
                        (_fromIndex + (_toIndex - _fromIndex) * pos) *
                                itemWidth +
                            itemWidth / 2;

                    // 计算指示器宽度（中心点 + 伸缩）
                    final indicatorWidth = (itemWidth - padding * 2) * scale;
                    final indicatorLeft = center - indicatorWidth / 2;

                    return Container(
                      width: indicatorWidth,
                      height: 44,
                      margin: EdgeInsets.only(left: indicatorLeft),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    );
                  },
                ),
              ),
              // 导航项层
              Row(
                children: List.generate(widget.items.length, (index) {
                  return _buildNavItem(index, itemWidth);
                }),
              ),
            ],
          );
        },
      ),
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
        height: 44,
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
            const SizedBox(width: 6),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

// ========================
// 悬浮底部导航栏
// ========================

/// 悬浮风格的底部导航栏
/// 将 ShardBottomNavBar 包裹在浮动卡片中
/// 背景使用 surfaceContainerHighest + 可选毛玻璃效果
class ShardFloatingBottomNavBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding + marginBottom),
      child: Card(
        elevation: 4,
        margin: EdgeInsets.zero,
        color: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: ShardBottomNavBar(
            items: items,
            selectedIndex: selectedIndex,
            onTap: onTap,
            showTopBorder: false,
          ),
        ),
      ),
    );
  }
}
