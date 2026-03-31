// ShardXL 其他设置页面（占位）
// lib/features/settings/pages/other_settings_page.dart

import 'package:flutter/material.dart';
import '../../../core/widgets/glass_card.dart';

class OtherSettingsPage extends StatelessWidget {
  const OtherSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(
                '其他设置',
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
                child: ListTile(
                  leading: const Icon(Icons.storage),
                  title: const Text('缓存管理'),
                  subtitle: const Text('清理临时文件'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 8),
              GlassCard(
                child: ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('下载源'),
                  subtitle: const Text('选择下载镜像'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 8),
              GlassCard(
                child: ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: const Text('调试模式'),
                  subtitle: const Text('显示调试信息'),
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
