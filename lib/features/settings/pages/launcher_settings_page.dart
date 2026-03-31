// ShardXL 启动器设置页面（占位）
// lib/features/settings/pages/launcher_settings_page.dart

import 'package:flutter/material.dart';
import '../../../core/widgets/glass_card.dart';

class LauncherSettingsPage extends StatelessWidget {
  const LauncherSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(
                '启动器设置',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            children: [
              GlassCard(
                child: SwitchListTile(
                  secondary: const Icon(Icons.notifications),
                  title: const Text('通知'),
                  subtitle: const Text('启用桌面通知'),
                  value: true,
                  onChanged: (_) {},
                ),
              ),
              const SizedBox(height: 8),
              GlassCard(
                child: SwitchListTile(
                  secondary: const Icon(Icons.system_update),
                  title: const Text('自动更新'),
                  subtitle: const Text('启动时检查更新'),
                  value: true,
                  onChanged: (_) {},
                ),
              ),
              const SizedBox(height: 8),
              GlassCard(
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
        ),
      ],
    );
  }
}
