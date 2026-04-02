// ShardXL 主页内容（shadcn-ui 风格）
// lib/features/home/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/shard_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/shadcn_button.dart';

/// 主页（shadcn-ui 风格）
class HomePageContent extends ConsumerWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // shadcn-ui 风格的标题区域
          Text(
            '欢迎使用 ShardXL',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '你的 Minecraft Java 版启动器',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          
          // shadcn-ui 风格的快速启动卡片
          GlassCard(
            onTap: () {},
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      themeExtension?.buttonBorderRadius ?? 10.0,
                    ),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 24,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '快速启动',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '选择版本并开始游戏',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // shadcn-ui 风格的功能卡片组
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  onTap: () {},
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            themeExtension?.buttonBorderRadius ?? 10.0,
                          ),
                        ),
                        child: Icon(
                          Icons.download,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '版本管理',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '下载和管理游戏版本',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassCard(
                  onTap: () {},
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            themeExtension?.buttonBorderRadius ?? 10.0,
                          ),
                        ),
                        child: Icon(
                          Icons.extension,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '模组管理',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '安装和管理游戏模组',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // shadcn-ui 风格的快速操作按钮
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
                  icon: Icons.inventory_2_rounded,
                  child: const Text('版本管理'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // shadcn-ui 风格的最近游戏卡片
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '最近游戏',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildRecentGameItem(
                  context,
                  'Minecraft 1.20.4',
                  'Fabric',
                  '2 小时前',
                ),
                const SizedBox(height: 8),
                _buildRecentGameItem(
                  context,
                  'Minecraft 1.19.2',
                  'Forge',
                  '昨天',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentGameItem(
    BuildContext context,
    String version,
    String loader,
    String time,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(
          themeExtension?.buttonBorderRadius ?? 10.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                (themeExtension?.buttonBorderRadius ?? 10.0) * 0.6,
              ),
            ),
            child: Icon(
              Icons.grass,
              size: 16,
              color: colorScheme.primary,
            ),
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
                Text(
                  loader,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
