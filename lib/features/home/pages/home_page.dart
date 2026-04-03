// ShardXL 主页内容（shadcn-ui 风格）
// lib/features/home/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/shard_theme.dart';
import '../../../core/widgets/shard_card.dart';
import '../../../core/widgets/shadcn_components.dart';
import '../../../core/widgets/shadcn_button.dart';

/// 主页（shadcn-ui 风格）
class HomePageContent extends ConsumerWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // shadcn-ui 风格的标题区域
          _buildHeader(context, colorScheme),
          const SizedBox(height: 16),
          
          // shadcn-ui 风格的统计卡片行
          _buildStatsRow(context, colorScheme, themeExtension),
          const SizedBox(height: 16),
          
          // shadcn-ui 风格的快速操作区域
          _buildQuickActions(context, colorScheme, themeExtension),
          const SizedBox(height: 16),
          
          // shadcn-ui 风格的最近游戏区域
          _buildRecentGames(context, colorScheme, themeExtension),
          const SizedBox(height: 16),
          
          // shadcn-ui 风格的新闻/更新区域
          _buildNewsSection(context, colorScheme, themeExtension),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '欢迎回来',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '准备开始你的 Minecraft 冒险了吗？',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            ShadcnAvatar(
              initials: 'SX',
              size: 48,
              backgroundColor: colorScheme.primaryContainer,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, ColorScheme colorScheme, ShardThemeExtension? themeExtension) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            colorScheme,
            themeExtension,
            icon: Icons.gamepad,
            value: '5',
            label: '游戏实例',
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            colorScheme,
            themeExtension,
            icon: Icons.extension,
            value: '12',
            label: '已安装模组',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            colorScheme,
            themeExtension,
            icon: Icons.schedule,
            value: '2h',
            label: '今日游戏',
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    ColorScheme colorScheme,
    ShardThemeExtension? themeExtension, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return ShardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                themeExtension?.buttonBorderRadius ?? 10.0,
              ),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ColorScheme colorScheme, ShardThemeExtension? themeExtension) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快速操作',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ShadcnButton(
                onPressed: () {},
                icon: Icons.play_arrow_rounded,
                child: const Text('启动游戏'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ShadcnButton(
                onPressed: () {},
                variant: ShadcnButtonVariant.outline,
                icon: Icons.download_rounded,
                child: const Text('下载版本'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentGames(BuildContext context, ColorScheme colorScheme, ShardThemeExtension? themeExtension) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '最近游戏',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('查看全部'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRecentGameItem(
          context,
          colorScheme,
          themeExtension,
          version: 'Minecraft 1.20.4',
          loader: 'Fabric',
          time: '2 小时前',
          iconData: Icons.grass,
          color: Colors.green,
        ),
        const SizedBox(height: 8),
        _buildRecentGameItem(
          context,
          colorScheme,
          themeExtension,
          version: 'Minecraft 1.19.2',
          loader: 'Forge',
          time: '昨天',
          iconData: Icons.construction,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildRecentGameItem(
    BuildContext context,
    ColorScheme colorScheme,
    ShardThemeExtension? themeExtension, {
    required String version,
    required String loader,
    required String time,
    required IconData iconData,
    required Color color,
  }) {
    return ShardCard(
      onTap: () {},
      hoverable: true,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                (themeExtension?.buttonBorderRadius ?? 10.0) * 0.8,
              ),
            ),
            child: Icon(iconData, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  version,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    ShadcnBadge(
                      text: loader,
                      variant: ShadcnBadgeVariant.outline,
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
              ],
            ),
          ),
          Icon(
            Icons.play_arrow_rounded,
            size: 20,
            color: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSection(BuildContext context, ColorScheme colorScheme, ShardThemeExtension? themeExtension) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最新动态',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        ShardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(
                        themeExtension?.buttonBorderRadius ?? 10.0,
                      ),
                    ),
                    child: Icon(
                      Icons.new_releases,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Minecraft 1.21 发布',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '新版本带来了许多新功能和改进',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const ShadcnBadge(text: '新', variant: ShadcnBadgeVariant.default_),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
