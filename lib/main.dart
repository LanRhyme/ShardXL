// ShardXL - Minecraft Java Edition Launcher
// lib/main.dart
//
// 顶部底部导航栏布局：主页、游戏实例、下载、碎片网络、设置

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'core/widgets/shard_background.dart';
import 'core/widgets/shard_bottom_nav_bar.dart';
import 'core/widgets/shard_window_title_bar.dart';
import 'core/theme/shard_scroll_behavior.dart';
import 'features/home/pages/home_page.dart';
import 'features/game_instance/pages/game_instance_page.dart';
import 'features/download/pages/download_page.dart';
import 'features/network/pages/network_page.dart';
import 'features/settings/pages/settings_page.dart';
import 'features/settings/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  if (Platform.isWindows) {
    await Window.initialize();
  }

  runApp(const ProviderScope(child: ShardXLApp()));

  doWhenWindowReady(() {
    const initialSize = Size(1200, 800);
    appWindow.minSize = const Size(800, 600);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class ShardXLApp extends ConsumerWidget {
  const ShardXLApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shardTheme = ref.watch(currentShardThemeProvider);

    return MaterialApp(
      title: 'ShardXL',
      debugShowCheckedModeBanner: false,
      theme: shardTheme.toThemeData(),
      scrollBehavior: const ShardScrollBehavior(),
      home: const HomePage(),
    );
  }
}

// ========================
// 主页面（底部导航布局）
// ========================

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  // 底部导航项配置
  static const _navItems = [
    NavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: '主页'),
    NavItem(
      icon: Icons.construction_outlined,
      selectedIcon: Icons.construction,
      label: '游戏实例',
    ),
    NavItem(
      icon: Icons.download_outlined,
      selectedIcon: Icons.download,
      label: '下载',
    ),
    NavItem(
      icon: Icons.language_outlined,
      selectedIcon: Icons.language,
      label: '碎片网络',
    ),
    NavItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: '设置',
    ),
  ];

  // 页面列表
  static const _pages = [
    HomePageContent(),
    GameInstancePage(),
    DownloadPage(),
    NetworkPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // 加载保存的主题配置
    Future.microtask(() {
      ref.read(shardThemeProvider.notifier).loadTheme();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final titleBarHeight = isDesktop ? 32.0 : 0.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ShardBackground(
        child: Column(
          children: [
            if (isDesktop) const ShardWindowTitleBar(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final navBarHeight = 70.0 + MediaQuery.of(context).padding.bottom;

                  return Stack(
                    children: [
                      Positioned.fill(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: KeyedSubtree(
                            key: ValueKey(_selectedIndex),
                            child: Padding(
                              padding: EdgeInsets.only(bottom: navBarHeight),
                              child: _pages[_selectedIndex],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: ShardBottomNavBar(
                          items: _navItems,
                          selectedIndex: _selectedIndex,
                          onTap: (index) => setState(() => _selectedIndex = index),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
