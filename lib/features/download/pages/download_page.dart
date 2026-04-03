import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/shard_bottom_nav_bar.dart';
import 'game_version_list_page.dart';

class DownloadPage extends ConsumerStatefulWidget {
  const DownloadPage({super.key});

  @override
  ConsumerState<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends ConsumerState<DownloadPage> {
  int _subSelectedIndex = 0;

  static const _subNavItems = [
    NavItem(
      icon: Icons.gamepad_outlined,
      selectedIcon: Icons.gamepad,
      label: '游戏',
    ),
    NavItem(
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      label: '整合包',
    ),
    NavItem(
      icon: Icons.extension_outlined,
      selectedIcon: Icons.extension,
      label: '模组',
    ),
    NavItem(
      icon: Icons.folder_special_outlined,
      selectedIcon: Icons.folder_special,
      label: '资源包',
    ),
    NavItem(
      icon: Icons.save_outlined,
      selectedIcon: Icons.save,
      label: '存档',
    ),
    NavItem(
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome,
      label: '光影包',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: KeyedSubtree(
              key: ValueKey(_subSelectedIndex),
              child: _buildSubPage(_subSelectedIndex),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ShardFloatingBottomNavBar(
            items: _subNavItems,
            selectedIndex: _subSelectedIndex,
            onTap: (index) => setState(() => _subSelectedIndex = index),
          ),
        ),
      ],
    );
  }

  Widget _buildSubPage(int index) {
    switch (index) {
      case 0:
        return const GameVersionListPage();
      case 1:
        return _buildComingSoonPage('整合包');
      case 2:
        return _buildComingSoonPage('模组');
      case 3:
        return _buildComingSoonPage('资源包');
      case 4:
        return _buildComingSoonPage('存档');
      case 5:
        return _buildComingSoonPage('光影包');
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildComingSoonPage(String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_outlined,
            size: 64,
            color: colorScheme.outline.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            '$title 功能即将上线',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '敬请期待',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
