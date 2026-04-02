// ShardXL 启动器设置页面（shadcn-ui 风格）
// lib/features/settings/pages/launcher_settings_page.dart

import 'package:flutter/material.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/shard_theme.dart';

class LauncherSettingsPage extends StatelessWidget {
  const LauncherSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 页面标题
          _buildHeader(context, colorScheme),
          const SizedBox(height: 20),
          
          // 通知设置
          _buildSettingsSection(
            context,
            colorScheme,
            themeExtension,
            title: '通知',
            icon: Icons.notifications,
            children: [
              _buildSwitchTile(
                context,
                colorScheme,
                icon: Icons.notifications,
                title: '桌面通知',
                subtitle: '接收游戏更新和重要通知',
                value: true,
                onChanged: (_) {},
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                context,
                colorScheme,
                icon: Icons.volume_up,
                title: '通知声音',
                subtitle: '播放通知提示音',
                value: true,
                onChanged: (_) {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 更新设置
          _buildSettingsSection(
            context,
            colorScheme,
            themeExtension,
            title: '更新',
            icon: Icons.system_update,
            children: [
              _buildSwitchTile(
                context,
                colorScheme,
                icon: Icons.system_update,
                title: '自动更新',
                subtitle: '启动时检查更新',
                value: true,
                onChanged: (_) {},
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                context,
                colorScheme,
                icon: Icons.download,
                title: '自动下载更新',
                subtitle: '在后台自动下载更新',
                value: false,
                onChanged: (_) {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 外观设置
          _buildSettingsSection(
            context,
            colorScheme,
            themeExtension,
            title: '外观',
            icon: Icons.palette,
            children: [
              _buildSettingTile(
                context,
                colorScheme,
                themeExtension,
                icon: Icons.language,
                title: '语言',
                subtitle: '简体中文',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildSettingTile(
                context,
                colorScheme,
                themeExtension,
                icon: Icons.view_module,
                title: '视图模式',
                subtitle: '网格视图',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 隐私设置
          _buildSettingsSection(
            context,
            colorScheme,
            themeExtension,
            title: '隐私',
            icon: Icons.security,
            children: [
              _buildSwitchTile(
                context,
                colorScheme,
                icon: Icons.analytics,
                title: '使用统计',
                subtitle: '帮助改进 ShardXL',
                value: true,
                onChanged: (_) {},
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                context,
                colorScheme,
                icon: Icons.cloud_upload,
                title: '云端同步',
                subtitle: '同步设置到云端',
                value: false,
                onChanged: (_) {},
              ),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '启动器设置',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '配置启动器的外观和行为',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    ColorScheme colorScheme,
    ShardThemeExtension? themeExtension, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    themeExtension?.buttonBorderRadius ?? 10.0,
                  ),
                ),
                child: Icon(icon, size: 18, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    ColorScheme colorScheme,
    ShardThemeExtension? themeExtension, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        themeExtension?.buttonBorderRadius ?? 10.0,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    ColorScheme colorScheme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}