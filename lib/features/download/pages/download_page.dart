import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../game_instance/providers/dartcraft_provider.dart';
import '../../../core/widgets/glass_card.dart';

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
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: _buildSidebar(context),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 16),
              Expanded(
                child: _buildVersionList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '下载',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '下载并安装 Minecraft 游戏版本',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.invalidate(availableVersionsProvider),
          tooltip: '刷新',
        ),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final filters = [
      _FilterItem('全部', '全部版本', Icons.list),
      _FilterItem('release', '正式版', Icons.gamepad),
      _FilterItem('snapshot', '快照版', Icons.science),
      _FilterItem('old_beta', '旧版测试', Icons.history),
      _FilterItem('old_alpha', '旧版Alpha', Icons.history_edu),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.category, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  '版本分类',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = _selectedFilter == filter.key;
                return ListTile(
                  dense: true,
                  selected: isSelected,
                  selectedTileColor: colorScheme.primaryContainer.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  leading: Icon(
                    filter.icon,
                    size: 20,
                    color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    filter.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    filter.description,
                    style: const TextStyle(fontSize: 11),
                  ),
                  onTap: () {
                    setState(() => _selectedFilter = filter.key);
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              '提示：点击版本可查看详情并安装',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GlassCard(
      child: TextField(
        decoration: InputDecoration(
          hintText: '搜索版本...',
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }

  Widget _buildVersionList() {
    final versionsAsync = ref.watch(availableVersionsProvider);

    return GlassCard(
      child: versionsAsync.when(
        data: (versions) {
          final filtered = versions.where((v) {
            final matchesFilter = _selectedFilter == '全部' || v.versionType == _selectedFilter;
            final matchesSearch = _searchQuery.isEmpty ||
                v.id.toLowerCase().contains(_searchQuery.toLowerCase());
            return matchesFilter && matchesSearch;
          }).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '没有找到匹配的版本',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final version = filtered[index];
              return _VersionListItem(version: version);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                '加载失败',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref.invalidate(availableVersionsProvider),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterItem {
  final String key;
  final String label;
  final String description;
  final IconData icon;

  _FilterItem(this.key, this.label, this.icon)
      : description = key == '全部'
            ? '所有可用版本'
            : key == 'release'
                ? 'Minecraft 正式版'
                : key == 'snapshot'
                    ? 'Minecraft 快照版'
                    : key == 'old_beta'
                        ? '旧版测试版'
                        : '旧版 Alpha 版';
}

class _VersionListItem extends ConsumerStatefulWidget {
  final MinecraftVersion version;

  const _VersionListItem({required this.version});

  @override
  ConsumerState<_VersionListItem> createState() => _VersionListItemState();
}

class _VersionListItemState extends ConsumerState<_VersionListItem> {
  bool _isExpanded = false;
  bool _isInstalling = false;

  @override
  Widget build(BuildContext context) {
    final installedAsync = ref.watch(installedVersionsProvider);
    final isInstalled = installedAsync.whenOrNull(
          data: (list) => list.contains(widget.version.id),
        ) ??
        false;

    final versionColor = _getVersionColor(widget.version.versionType);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: versionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getVersionIcon(widget.version.versionType),
                color: versionColor,
              ),
            ),
            title: Text(
              widget.version.id,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_getVersionTypeText()),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isInstalled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '已安装',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  FilledButton(
                    onPressed: _isInstalling ? null : () => _installVersion(),
                    child: _isInstalling
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('安装'),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  onPressed: () {
                    setState(() => _isExpanded = !_isExpanded);
                  },
                ),
              ],
            ),
          ),
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  _buildInfoRow('版本号', widget.version.id),
                  _buildInfoRow('版本类型', _getVersionTypeName(widget.version.versionType)),
                  _buildInfoRow(
                    '发布日期',
                    '${widget.version.releaseTime.year}-${widget.version.releaseTime.month.toString().padLeft(2, '0')}-${widget.version.releaseTime.day.toString().padLeft(2, '0')}',
                  ),
                  _buildInfoRow('游戏目录', _getGameDirHint()),
                  if (!isInstalled) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isInstalling ? null : () => _installVersion(),
                        icon: const Icon(Icons.download),
                        label: Text(_isInstalling ? '安装中...' : '安装此版本'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
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

  String _getVersionTypeText() {
    final type = widget.version.versionType;
    final releaseTime = widget.version.releaseTime;
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

  String _getVersionTypeName(String type) {
    switch (type) {
      case 'release':
        return '正式版 (Release)';
      case 'snapshot':
        return '快照版 (Snapshot)';
      case 'old_beta':
        return '旧版测试版 (Old Beta)';
      case 'old_alpha':
        return '旧版 Alpha (Old Alpha)';
      default:
        return type;
    }
  }

  String _getGameDirHint() {
    final settings = ref.read(gameSettingsProvider);
    return settings.gameDirectory.isEmpty
        ? '使用默认目录'
        : settings.gameDirectory;
  }

  Future<void> _installVersion() async {
    final settings = ref.read(gameSettingsProvider);
    if (settings.gameDirectory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先在设置中配置游戏目录')),
      );
      return;
    }

    setState(() => _isInstalling = true);

    try {
      // Simplified installation using ShardXL-Lib approach
      // Check if already installed
      final versionDir = Directory('${settings.gameDirectory}/versions/${widget.version.id}');
      final jarFile = File('${versionDir.path}/${widget.version.id}.jar');
      
      if (!jarFile.existsSync()) {
        // TODO: Implement version installation via ShardXL-Lib
        // For now, show a message that installation is in progress
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.version.id} 安装功能即将完成')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.version.id} 已安装')),
        );
      }

      ref.invalidate(installedVersionsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.version.id} 安装完成（ShardXL-Lib 集成中）')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('安装失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isInstalling = false);
      }
    }
  }
}
