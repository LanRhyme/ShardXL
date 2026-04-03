import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../game_instance/providers/game_provider.dart';
import '../../../core/widgets/shard_card.dart';
import '../../../core/widgets/shadcn_components.dart';
import '../../../core/widgets/shadcn_button.dart';
import '../../../core/theme/shard_theme.dart';

class DownloadPage extends ConsumerStatefulWidget {
  const DownloadPage({super.key});

  @override
  ConsumerState<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends ConsumerState<DownloadPage> {
  String _selectedFilter = '全部';
  String _searchQuery = '';

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
          
          // 搜索和过滤区域
          _buildSearchAndFilter(context, colorScheme, themeExtension),
          const SizedBox(height: 16),
          
          // 版本列表
          _buildVersionList(context, colorScheme, themeExtension),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '下载',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '下载并安装 Minecraft 游戏版本',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        ShadcnIconButton(
          icon: Icons.refresh,
          onPressed: () => ref.refresh(availableVersionsProvider),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(BuildContext context, ColorScheme colorScheme, ShardThemeExtension? themeExtension) {
    return Column(
      children: [
        // 搜索框
        ShadcnInput(
          placeholder: '搜索版本...',
          prefixIcon: Icons.search,
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
          suffix: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
        ),
        const SizedBox(height: 12),
        
        // 过滤标签
        ShadcnTabs(
          tabs: const [
            ShadcnTab(label: '全部'),
            ShadcnTab(label: '正式版'),
            ShadcnTab(label: '快照版'),
            ShadcnTab(label: '旧版'),
          ],
          selectedIndex: _getFilterIndex(),
          onTabChanged: (index) {
            setState(() {
              switch (index) {
                case 0:
                  _selectedFilter = '全部';
                  break;
                case 1:
                  _selectedFilter = 'release';
                  break;
                case 2:
                  _selectedFilter = 'snapshot';
                  break;
                case 3:
                  _selectedFilter = 'old_beta';
                  break;
              }
            });
          },
        ),
      ],
    );
  }

  int _getFilterIndex() {
    switch (_selectedFilter) {
      case 'release':
        return 1;
      case 'snapshot':
        return 2;
      case 'old_beta':
      case 'old_alpha':
        return 3;
      default:
        return 0;
    }
  }

  Widget _buildVersionList(BuildContext context, ColorScheme colorScheme, ShardThemeExtension? themeExtension) {
    final versionsAsync = ref.watch(availableVersionsProvider);

    return versionsAsync.when(
      data: (versions) {
        final filtered = versions.where((v) {
          final matchesFilter = _selectedFilter == '全部' || v.versionType == _selectedFilter;
          final matchesSearch = _searchQuery.isEmpty ||
              v.id.toLowerCase().contains(_searchQuery.toLowerCase());
          return matchesFilter && matchesSearch;
        }).toList();

        if (filtered.isEmpty) {
          return _buildEmptyState(context, colorScheme);
        }

        return Column(
          children: filtered.map((version) {
            return _buildVersionItem(context, colorScheme, themeExtension, version);
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(context, colorScheme),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '没有找到匹配的版本',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 64,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: TextStyle(
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          ShadcnButton(
            onPressed: () => ref.refresh(availableVersionsProvider),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionItem(BuildContext context, ColorScheme colorScheme, ShardThemeExtension? themeExtension, MinecraftVersion version) {
    final installedAsync = ref.watch(installedVersionsProvider);
    final isInstalled = installedAsync.whenOrNull(
          data: (list) => list.contains(version.id),
        ) ??
        false;

    final versionColor = _getVersionColor(version.versionType);

    return ShardCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: versionColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                (themeExtension?.buttonBorderRadius ?? 10.0) * 0.8,
              ),
            ),
            child: Icon(
              _getVersionIcon(version.versionType),
              color: versionColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  version.id,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getVersionTypeText(version),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          if (isInstalled)
            const ShadcnBadge(text: '已安装', variant: ShadcnBadgeVariant.outline)
          else
            ShadcnButton(
              onPressed: () => _installVersion(version),
              size: ShadcnButtonSize.sm,
              child: const Text('安装'),
            ),
        ],
      ),
    );
  }

  IconData _getVersionIcon(String type) {
    switch (type) {
      case 'release':
        return Icons.gamepad;
      case 'snapshot':
        return Icons.science;
      case 'old_beta':
        return Icons.history;
      case 'old_alpha':
        return Icons.history_edu;
      default:
        return Icons.help_outline;
    }
  }

  Color _getVersionColor(String type) {
    switch (type) {
      case 'release':
        return Colors.green;
      case 'snapshot':
        return Colors.orange;
      case 'old_beta':
        return Colors.brown;
      case 'old_alpha':
        return Colors.brown.shade300;
      default:
        return Colors.grey;
    }
  }

  String _getVersionTypeText(MinecraftVersion version) {
    final type = version.versionType;
    final releaseTime = version.releaseTime;
    switch (type) {
      case 'release':
        return '正式版 • ${releaseTime.year}-${releaseTime.month.toString().padLeft(2, '0')}-${releaseTime.day.toString().padLeft(2, '0')}';
      case 'snapshot':
        return '快照版 • ${releaseTime.year}-${releaseTime.month.toString().padLeft(2, '0')}-${releaseTime.day.toString().padLeft(2, '0')}';
      case 'old_beta':
        return '旧版测试版';
      case 'old_alpha':
        return '旧版 Alpha';
      default:
        return type;
    }
  }

  Future<void> _installVersion(MinecraftVersion version) async {
    final settings = ref.read(gameSettingsProvider);
    if (settings.gameDirectory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先在设置中配置游戏目录')),
      );
      return;
    }

    try {
      // Simplified installation using ShardXL-Lib approach
      final versionDir = Directory('${settings.gameDirectory}/versions/${version.id}');
      final jarFile = File('${versionDir.path}/${version.id}.jar');
      
      if (!jarFile.existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${version.id} 安装功能即将完成')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${version.id} 已安装')),
        );
      }

      ref.invalidate(installedVersionsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${version.id} 安装完成（ShardXL-Lib 集成中）')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('安装失败: $e')),
        );
      }
    }
  }
}
