// ShardXL 启动器设置页面（占位）
// lib/features/settings/pages/launcher_settings_page.dart

import 'package:flutter/material.dart';

class LauncherSettingsPage extends StatelessWidget {
  const LauncherSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('启动器设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications),
              title: const Text('通知'),
              subtitle: const Text('启用桌面通知'),
              value: true,
              onChanged: (_) {},
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.system_update),
              title: const Text('自动更新'),
              subtitle: const Text('启动时检查更新'),
              value: true,
              onChanged: (_) {},
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: const Text('语言'),
              subtitle: const Text('简体中文'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
