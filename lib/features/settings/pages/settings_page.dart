// ShardXL 设置页面（含悬浮子导航栏）
// lib/features/settings/pages/settings_page.dart
//
// 内置悬浮导航栏切换子页面：全局游戏设置、启动器设置、主题、其他设置、关于

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

class _SettingsPageState extends State<SettingsPage> {
  int _subIndex = 0;

  // 子页面导航项配置
  static const _subNavItems = [
    NavItem(
      icon: Icons.sports_esports_outlined,
      selectedIcon: Icons.sports_esports,
      label: '全局游戏',
    ),
    NavItem(
      icon: Icons.rocket_launch_outlined,
      selectedIcon: Icons.rocket_launch,
      label: '启动器',
    ),
    NavItem(
      icon: Icons.palette_outlined,
      selectedIcon: Icons.palette,
      label: '主题',
    ),
    NavItem(
      icon: Icons.tune_outlined,
      selectedIcon: Icons.tune,
      label: '其他',
    ),
    NavItem(
      icon: Icons.info_outline,
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
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 子页面内容
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: KeyedSubtree(
            key: ValueKey(_subIndex),
            child: _pages[_subIndex],
          ),
        ),
        // 悬浮底部导航栏
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ShardFloatingBottomNavBar(
            items: _subNavItems,
            selectedIndex: _subIndex,
            onTap: (index) => setState(() => _subIndex = index),
          ),
        ),
      ],
    );
  }
}
