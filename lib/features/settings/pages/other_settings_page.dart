// ShardXL 其他设置页面（shadcn-ui 风格）
// lib/features/settings/pages/other_settings_page.dart

import 'package:flutter/material.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/shadcn_components.dart';
import '../../../core/widgets/faded_edge_scroll_view.dart';

class OtherSettingsPage extends StatelessWidget {
  const OtherSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FadedEdgeWrapper(
      scrollView: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, colorScheme),
            const SizedBox(height: 20),
          _buildSettingsSection(
            context,
            colorScheme,
            title: '存储',
            icon: Icons.storage_outlined,
            children: [
              _buildSettingTile(
                context,
                colorScheme,
                icon: Icons.folder_outlined,
                title: '缓存管理',
                subtitle: '清理临时文件，释放磁盘空间',
                trailing: const ShadcnBadge(
                  text: '128 MB',
                  variant: ShadcnBadgeVariant.secondary,
                ),
                onTap: () {},
              ),
              const SizedBox(height: 8),
              _buildSettingTile(
                context,
                colorScheme,
                icon: Icons.delete_outline_outlined,
                title: '清除下载缓存',
                subtitle: '删除未完成的下载文件',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsSection(
            context,
            colorScheme,
            title: '下载',
            icon: Icons.download_outlined,
            children: [
              _buildSettingTile(
                context,
                colorScheme,
                icon: Icons.cloud_download_outlined,
                title: '下载源',
                subtitle: '选择下载镜像服务器',
                trailing: const ShadcnBadge(
                  text: '官方',
                  variant: ShadcnBadgeVariant.default_,
                ),
                onTap: () {},
              ),
              const SizedBox(height: 8),
              _buildSettingTile(
                context,
                colorScheme,
                icon: Icons.speed_outlined,
                title: '下载限速',
                subtitle: '限制最大下载速度',
                trailing: ShadcnBadge(
                  text: '无限制',
                  variant: ShadcnBadgeVariant.outline,
                ),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsSection(
            context,
            colorScheme,
            title: '开发者',
            icon: Icons.code_outlined,
            children: [
              _buildSwitchTile(
                context,
                colorScheme,
                icon: Icons.bug_report_outlined,
                title: '调试模式',
                subtitle: '显示详细调试信息',
                value: false,
                onChanged: (value) {},
              ),
              const SizedBox(height: 8),
              _buildSwitchTile(
                context,
                colorScheme,
                icon: Icons.terminal_outlined,
                title: '控制台输出',
                subtitle: '显示游戏控制台日志',
                value: true,
                onChanged: (value) {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsSection(
            context,
            colorScheme,
            title: '实验性',
            icon: Icons.science_outlined,
            children: [
              _buildSwitchTile(
                context,
                colorScheme,
                icon: Icons.flash_on_outlined,
                title: '硬件加速',
                subtitle: '启用 GPU 加速渲染',
                value: true,
                onChanged: (value) {},
              ),
              const SizedBox(height: 8),
              _buildSettingTile(
                context,
                colorScheme,
                icon: Icons.extension_outlined,
                title: '插件系统',
                subtitle: '加载第三方插件扩展功能',
                trailing: ShadcnBadge(
                  text: 'Beta',
                  variant: ShadcnBadgeVariant.secondary,
                ),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '其他设置',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '配置存储、下载和开发选项',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    ColorScheme colorScheme, {
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
                  borderRadius: BorderRadius.circular(8),
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
    ColorScheme colorScheme, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
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
            if (trailing != null) ...[
              trailing,
              const SizedBox(width: 8),
            ],
            Icon(
              Icons.chevron_right_outlined,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
