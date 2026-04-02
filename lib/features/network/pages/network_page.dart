// ShardXL 碎片网络页面（shadcn-ui 风格）
// lib/features/network/pages/network_page.dart

import 'package:flutter/material.dart';
import '../../../core/theme/shard_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/shadcn_components.dart';
import '../../../core/widgets/shadcn_button.dart';

class NetworkPage extends StatelessWidget {
  const NetworkPage({super.key});

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
          const SizedBox(height: 16),
          
          // 功能标签页
          _buildFeatureTabs(context, colorScheme, themeExtension),
          const SizedBox(height: 16),
          
          // 热门模组区域
          _buildPopularMods(context, colorScheme, themeExtension),
          const SizedBox(height: 16),
          
          // 社区动态区域
          _buildCommunityUpdates(context, colorScheme, themeExtension),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '碎片网络',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '发现模组、资源包和社区内容',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildFeatureTabs(BuildContext context, ColorScheme colorScheme, ShardThemeExtension? themeExtension) {
    return ShadcnTabs(
      tabs: const [
        ShadcnTab(label: '模组', icon: Icons.extension),
        ShadcnTab(label: '资源包', icon: Icons.palette),
        ShadcnTab(label: '光影', icon: Icons.lightbulb),
        ShadcnTab(label: '整合包', icon: Icons.inventory_2),
      ],
      selectedIndex: 0,
      onTabChanged: (index) {},
    );
  }

  Widget _buildPopularMods(BuildContext context, ColorScheme colorScheme, ShardThemeExtension? themeExtension) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '热门模组',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('查看更多'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return _buildModCard(
                context,
                colorScheme,
                themeExtension,
                title: 'JEI (Just Enough Items)',
                description: '物品管理模组',
                downloads: '50M+',
                color: Colors.blue,
                icon: Icons.list_alt,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModCard(
    BuildContext context,
    ColorScheme colorScheme,
    ShardThemeExtension? themeExtension, {
    required String title,
    required String description,
    required String downloads,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  (themeExtension?.buttonBorderRadius ?? 10.0) * 0.8,
                ),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.download, size: 14, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  downloads,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityUpdates(BuildContext context, ColorScheme colorScheme, ShardThemeExtension? themeExtension) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '社区动态',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            children: [
              _buildUpdateItem(
                context,
                colorScheme,
                themeExtension,
                avatar: 'MC',
                username: 'Minecraft 官方',
                content: 'Minecraft 1.21 版本现已发布！',
                time: '2 小时前',
                color: Colors.green,
              ),
              const ShadcnSeparator(),
              const SizedBox(height: 12),
              _buildUpdateItem(
                context,
                colorScheme,
                themeExtension,
                avatar: 'FA',
                username: 'Fabric 团队',
                content: 'Fabric API 更新至 0.92.0 版本',
                time: '5 小时前',
                color: Colors.pink,
              ),
              const ShadcnSeparator(),
              const SizedBox(height: 12),
              _buildUpdateItem(
                context,
                colorScheme,
                themeExtension,
                avatar: 'FO',
                username: 'Forge 团队',
                content: 'Forge 1.20.4 稳定版发布',
                time: '昨天',
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateItem(
    BuildContext context,
    ColorScheme colorScheme,
    ShardThemeExtension? themeExtension, {
    required String avatar,
    required String username,
    required String content,
    required String time,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShadcnAvatar(
          initials: avatar,
          size: 40,
          backgroundColor: color.withValues(alpha: 0.1),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    username,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
