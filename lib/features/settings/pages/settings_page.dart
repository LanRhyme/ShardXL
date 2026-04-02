// ShardXL 设置页面（含悬浮子导航栏）
// lib/features/settings/pages/settings_page.dart
//
// 内置悬浮导航栏切换子页面：全局游戏设置、启动器设置、主题、其他设置、关于

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/widgets/shard_bottom_nav_bar.dart';
import 'theme_settings_page.dart';
import 'game_settings_page.dart';
import 'launcher_settings_page.dart';
import 'other_settings_page.dart';
import 'about_page.dart';

/// 设置页面
/// 使用悬浮底部导航栏切换五个子页面
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  int _subIndex = 0;
  late AnimationController _navAnimController;
  late Animation<Offset> _navSlideAnimation;
  bool _isNavVisible = true;
  Timer? _showTimer;

  // 子页面导航项配置
  static const _subNavItems = [
    NavItem(
      icon: Icons.games_outlined,
      selectedIcon: Icons.games,
      label: '全局游戏',
    ),
    NavItem(
      icon: Icons.rocket_outlined,
      selectedIcon: Icons.rocket,
      label: '启动器',
    ),
    NavItem(
      icon: Icons.palette_outlined,
      selectedIcon: Icons.palette,
      label: '主题',
    ),
    NavItem(
      icon: Icons.more_horiz_outlined,
      selectedIcon: Icons.more_horiz,
      label: '其他',
    ),
    NavItem(
      icon: Icons.info_outlined,
      selectedIcon: Icons.info,
      label: '关于',
    ),
  ];

  // 子页面列表
  static const _pages = [
    GameSettingsPage(),
    LauncherSettingsPage(),
    ThemeSettingsPage(),
    OtherSettingsPage(),
    AboutPage(),
  ];

  @override
  void initState() {
    super.initState();
    _navAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _navSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 2.5),
    ).animate(CurvedAnimation(
      parent: _navAnimController,
      curve: Curves.easeOutQuart,
    ));
  }

  @override
  void dispose() {
    _navAnimController.dispose();
    super.dispose();
  }

  void _hideNavBar() {
    if (_isNavVisible) {
      _isNavVisible = false;
      _navAnimController.forward();
    }
  }

  void _showNavBar() {
    if (!_isNavVisible) {
      _isNavVisible = true;
      _navAnimController.reverse();
    }
  }

  void _onScrollUpdate() {
    _hideNavBar();
  }

  void _onScrollEnd() {
    _showTimer?.cancel();
    _showTimer = Timer(const Duration(milliseconds: 300), _showNavBar);
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _hideNavBar();
    } else if (notification is ScrollUpdateNotification) {
      _onScrollUpdate();
    } else if (notification is ScrollEndNotification) {
      _onScrollEnd();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 子页面内容
        NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: KeyedSubtree(
              key: ValueKey(_subIndex),
              child: _pages[_subIndex],
            ),
          ),
        ),
        // 悬浮底部导航栏
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SlideTransition(
            position: _navSlideAnimation,
            child: ShardFloatingBottomNavBar(
              items: _subNavItems,
              selectedIndex: _subIndex,
              onTap: (index) => setState(() => _subIndex = index),
              marginBottom: 0,
            ),
          ),
        ),
      ],
    );
  }
}
