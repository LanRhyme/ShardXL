// ShardXL 关于页面（shadcn-ui 风格）
// lib/features/settings/pages/about_page.dart

import 'package:flutter/material.dart';
import '../../../core/widgets/shard_card.dart';
import '../../../core/widgets/shadcn_components.dart';
import '../../../core/widgets/faded_edge_scroll_view.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FadedEdgeWrapper(
      scrollView: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, colorScheme),
            const SizedBox(height: 20),
          
          // Logo 和名称
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.catching_pokemon_outlined,
                    size: 48,
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'ShardXL',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Minecraft Java Edition Launcher',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // 版本信息
          ShardCard(
            child: Column(
              children: [
                _buildInfoTile(
                  context,
                  icon: Icons.tag_outlined,
                  title: '版本',
                  trailing: ShadcnBadge(
                    text: '0.1.0-alpha',
                    variant: ShadcnBadgeVariant.default_,
                  ),
                ),
                const ShadcnSeparator(),
                _buildInfoTile(
                  context,
                  icon: Icons.code_outlined,
                  title: '框架',
                  trailing: Text(
                    'Flutter 3.x',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const ShadcnSeparator(),
                _buildInfoTile(
                  context,
                  icon: Icons.flutter_dash_outlined,
                  title: '目标平台',
                  trailing: Text(
                    'Windows / macOS / Linux',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const ShadcnSeparator(),
                _buildInfoTile(
                  context,
                  icon: Icons.copyright_outlined,
                  title: '开源协议',
                  trailing: ShadcnBadge(
                    text: 'MIT License',
                    variant: ShadcnBadgeVariant.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 相关链接
          ShardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '相关链接',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLinkTile(
                  context,
                  colorScheme,
                  icon: Icons.home_outlined,
                  title: '官方网站',
                  subtitle: 'shardxl.example.com',
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                _buildLinkTile(
                  context,
                  colorScheme,
                  icon: Icons.bug_report_outlined,
                  title: '问题反馈',
                  subtitle: 'GitHub Issues',
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                _buildLinkTile(
                  context,
                  colorScheme,
                  icon: Icons.book_outlined,
                  title: '使用文档',
                  subtitle: 'docs.shardxl.example.com',
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                _buildLinkTile(
                  context,
                  colorScheme,
                  icon: Icons.chat_outlined,
                  title: '社区交流',
                  subtitle: 'Discord / QQ 群',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 致谢
          ShardCard(
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
                      child: Icon(
                        Icons.favorite_outline,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '致谢',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'ShardXL 基于以下开源项目构建：',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCreditItem(context, 'Flutter', 'Google'),
                _buildCreditItem(context, 'Riverpod', 'Remi Rousselet'),
                _buildCreditItem(context, 'window_manager', 'LeanFlutter'),
                _buildCreditItem(context, 'flutter_acrylic', 'crebomare'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // 版权声明
          Center(
            child: Text(
              '© 2024 ShardXL Team. All rights reserved.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
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
          '关于',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '了解 ShardXL 的相关信息',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }

  Widget _buildLinkTile(
    BuildContext context,
    ColorScheme colorScheme, {
    required IconData icon,
    required String title,
    required String subtitle,
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
              Icons.arrow_outward_outlined,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditItem(BuildContext context, String project, String author) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            project,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            'by $author',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
