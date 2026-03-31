import 'package:dartcraft/dartcraft.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/dartcraft_provider.dart';

class DownloadPage extends ConsumerStatefulWidget {
  const DownloadPage({super.key});

  @override
  ConsumerState<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends ConsumerState<DownloadPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterType = '全部';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '下载',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '下载游戏版本、模组加载器和资源包',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '版本列表'),
              Tab(text: '安装包'),
            ],
          ),
          const SizedBox(height: 16),
          _buildFilterChips(),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVersionList(),
                _buildModLoaders(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final types = ['全部', 'release', 'snapshot', 'old'];
    return Wrap(
      spacing: 8,
      children: types.map((type) {
        final isSelected = _filterType == type;
        return FilterChip(
          label: Text(type == '全部' ? '全部' : type.toUpperCase()),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _filterType = type);
          },
        );
      }).toList(),
    );
  }

  Widget _buildVersionList() {
    final versionsAsync = ref.watch(availableVersionsProvider);

    return versionsAsync.when(
      data: (versions) {
        final filtered = _filterType == '全部'
            ? versions
            : versions.where((v) => v.type.name == _filterType).toList();

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final version = filtered[index];
            return _VersionCard(version: version);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('加载失败: $error'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.refresh(availableVersionsProvider),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModLoaders() {
    return const Center(
      child: Text('模组加载器支持开发中...'),
    );
  }
}

class _VersionCard extends ConsumerStatefulWidget {
  final MinecraftVersion version;

  const _VersionCard({required this.version});

  @override
  ConsumerState<_VersionCard> createState() => _VersionCardState();
}

class _VersionCardState extends ConsumerState<_VersionCard> {
  bool _isInstalling = false;
  double _installProgress = 0;

  @override
  Widget build(BuildContext context) {
    final installedAsync = ref.watch(installedVersionsProvider);
    final isInstalled = installedAsync.whenOrNull(
          data: (list) => list.contains(widget.version.id),
        ) ??
        false;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _buildVersionIcon(),
        title: Text(widget.version.id),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getVersionTypeText()),
            if (_isInstalling)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(value: _installProgress),
              ),
          ],
        ),
        trailing: isInstalled
            ? const Chip(
                label: Text('已安装'),
                backgroundColor: Colors.green,
              )
            : FilledButton(
                onPressed: _isInstalling ? null : () => _installVersion(),
                child: _isInstalling
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('安装'),
              ),
        isThreeLine: _isInstalling,
      ),
    );
  }

  Widget _buildVersionIcon() {
    IconData icon;
    Color color;

    switch (widget.version.type.name) {
      case 'release':
        icon = Icons.gamepad;
        color = Colors.green;
        break;
      case 'snapshot':
        icon = Icons.science;
        color = Colors.orange;
        break;
      case 'old_beta':
        icon = Icons.history;
        color = Colors.brown;
        break;
      case 'old_alpha':
        icon = Icons.history_edu;
        color = Colors.brown;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color),
    );
  }

  String _getVersionTypeText() {
    final type = widget.version.type.name;
    final releaseTime = widget.version.releaseTime;
    switch (type) {
      case 'release':
        return '正式版 • ${releaseTime.year}-${releaseTime.month.toString().padLeft(2, '0')}-${releaseTime.day.toString().padLeft(2, '0')}';
      case 'snapshot':
        return '快照版 • ${releaseTime.year}-${releaseTime.month.toString().padLeft(2, '0')}-${releaseTime.day.toString().padLeft(2, '0')}';
      case 'old_beta':
        return '旧版测试版';
      case 'old_alpha':
        return '旧版alpha';
      default:
        return type;
    }
  }

  Future<void> _installVersion() async {
    final settings = ref.read(gameSettingsProvider);
    if (settings.gameDirectory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先在设置中配置游戏目录')),
      );
      return;
    }

    setState(() {
      _isInstalling = true;
      _installProgress = 0;
    });

    try {
      final launcher = Dartcraft(
        widget.version.id,
        settings.gameDirectory,
        javaPath: settings.javaPath.isNotEmpty ? settings.javaPath : null,
      );

      if (!launcher.isInstalled) {
        await launcher.install();
      }

      ref.refresh(installedVersionsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.version.id} 安装完成')),
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
        setState(() {
          _isInstalling = false;
        });
      }
    }
  }
}
