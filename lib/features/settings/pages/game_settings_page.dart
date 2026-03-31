// ShardXL 全局游戏设置页面（占位）
// lib/features/settings/pages/game_settings_page.dart

import 'package:flutter/material.dart';

class GameSettingsPage extends StatelessWidget {
  const GameSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('全局游戏设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Java 路径
          Card(
            child: ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Java 路径'),
              subtitle: const Text('自动检测 / 手动设置'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          // 内存分配
          Card(
            child: ListTile(
              leading: const Icon(Icons.memory),
              title: const Text('内存分配'),
              subtitle: const Text('4096 MB'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          // 游戏目录
          Card(
            child: ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('游戏目录'),
              subtitle: const Text('.minecraft'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          // 游戏窗口
          Card(
            child: ListTile(
              leading: const Icon(Icons.aspect_ratio),
              title: const Text('游戏窗口'),
              subtitle: const Text('分辨率、全屏等'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
