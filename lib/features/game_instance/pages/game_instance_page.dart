import 'package:dartcraft/dartcraft.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/pages/auth_page.dart';
import '../providers/dartcraft_provider.dart';
import '../providers/game_instances_provider.dart';
import '../../../core/widgets/glass_card.dart';
import 'instance_config_page.dart';

class GameInstancePage extends ConsumerStatefulWidget {
  const GameInstancePage({super.key});

  @override
  ConsumerState<GameInstancePage> createState() => _GameInstancePageState();
}

class _GameInstancePageState extends ConsumerState<GameInstancePage> {
  String _searchQuery = '';
  String _selectedFilter = '全部';
  String? _selectedVersion;
  int _selectedMenuIndex = 0;

  final List<String> _filters = ['全部', '原版', '模组加载器'];

  final List<_MenuItem> _menuItems = const [
    _MenuItem(icon: Icons.grid_view, label: '实例概览'),
    _MenuItem(icon: Icons.settings, label: '运行配置'),
    _MenuItem(icon: Icons.extension, label: '模组仓库'),
    _MenuItem(icon: Icons.save, label: '存档管理'),
    _MenuItem(icon: Icons.palette, label: '资源中心'),
    _MenuItem(icon: Icons.lightbulb, label: '视觉光影'),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(gameSettingsProvider.notifier).loadSettings();
      ref.read(authProvider.notifier).loadSavedAuth();
      ref.read(gameInstancesProvider.notifier).loadInstances();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final installedAsync = ref.watch(installedVersionsProvider);
    final gameSettings = ref.watch(gameSettingsProvider);

    return Row(
      children: [
        // 左侧侧边栏
        _buildSidebar(),
        // 右侧内容区
        Expanded(
          child: Column(
            children: [
              // 顶部搜索栏
              _buildSearchHeader(),
              // 标签筛选
              _buildFilterTabs(),
              const SizedBox(height: 16),
              // 版本网格
              Expanded(
                child: installedAsync.when(
                  data: (versions) {
                    final filteredVersions = _filterVersions(versions);
                    if (filteredVersions.isEmpty) {
                      return const Center(
                        child: Text('暂无符合条件的版本'),
                      );
                    }
                    return _buildVersionGrid(filteredVersions, gameSettings, authState);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('加载失败: $e')),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 当前选中版本显示
            if (_selectedVersion != null)
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF5D8C38),
                            Color(0xFF8B7355),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.grass, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedVersion!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            if (_selectedVersion != null)
              const Divider(height: 1),
            // 菜单项
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  final isSelected = _selectedMenuIndex == index;
                  return _buildMenuItem(item, index, isSelected);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item, int index, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        onTap: () {
          setState(() => _selectedMenuIndex = index);
          if (index == 1 && _selectedVersion != null) {
            // 运行配置
            _showConfigDialog(_selectedVersion!);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 18,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 24, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '查找游戏实例...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {
              ref.refresh(installedVersionsProvider);
            },
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
          ),
          IconButton(
            onPressed: () {
              _showCreateInstanceDialog();
            },
            icon: const Icon(Icons.add),
            tooltip: '新建实例',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(filter),
              onSelected: (selected) {
                setState(() => _selectedFilter = filter);
              },
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<String> _filterVersions(List<String> versions) {
    return versions.where((version) {
      if (_searchQuery.isNotEmpty && !version.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_selectedFilter == '原版') {
        return !version.toLowerCase().contains('forge') &&
               !version.toLowerCase().contains('fabric') &&
               !version.toLowerCase().contains('quilt') &&
               !version.toLowerCase().contains('neoforge');
      } else if (_selectedFilter == '模组加载器') {
        return version.toLowerCase().contains('forge') ||
               version.toLowerCase().contains('fabric') ||
               version.toLowerCase().contains('quilt') ||
               version.toLowerCase().contains('neoforge');
      }
      return true;
    }).toList();
  }

  Widget _buildVersionGrid(List<String> versions, GameSettings settings, authState) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 24, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: versions.length,
      itemBuilder: (context, index) {
        final version = versions[index];
        final isSelected = _selectedVersion == version;
        return _buildVersionCard(version, settings, authState, isSelected);
      },
    );
  }

  Widget _buildVersionCard(String version, GameSettings settings, authState, bool isSelected) {
    final isModded = version.toLowerCase().contains('forge') ||
                     version.toLowerCase().contains('fabric') ||
                     version.toLowerCase().contains('quilt') ||
                     version.toLowerCase().contains('neoforge');

    return GlassCard(
      onTap: () {
        setState(() => _selectedVersion = version);
      },
      child: Stack(
        children: [
          // 选中边框
          if (isSelected)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          // 内容区域
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF5D8C38),
                        Color(0xFF8B7355),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.grass, size: 32, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  version,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isModded
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isModded ? '模组' : '原版',
                    style: TextStyle(
                      fontSize: 10,
                      color: isModded ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 更多选项按钮
          Positioned(
            top: 8,
            right: 8,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'launch',
                  child: Row(
                    children: [
                      Icon(Icons.play_arrow, size: 18),
                      SizedBox(width: 8),
                      Text('启动'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'config',
                  child: Row(
                    children: [
                      Icon(Icons.settings, size: 18),
                      SizedBox(width: 8),
                      Text('配置'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'folder',
                  child: Row(
                    children: [
                      Icon(Icons.folder_open, size: 18),
                      SizedBox(width: 8),
                      Text('打开目录'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('删除', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'launch':
                    _launchGame(version, authState, settings);
                    break;
                  case 'config':
                    _showConfigDialog(version);
                    break;
                  case 'folder':
                    _openInstanceFolder(version, settings);
                    break;
                  case 'delete':
                    _showDeleteConfirmDialog(version);
                    break;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showConfigDialog(String version) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        pageBuilder: (context, animation, secondaryAnimation) {
          return GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.85,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: InstanceConfigPage(version: version),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  void _showCreateInstanceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建游戏实例'),
        content: const Text('请前往下载页面安装新版本'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('前往下载'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(String version) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除版本 $version 吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$version 已删除')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _openInstanceFolder(String version, GameSettings settings) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('打开 $version 目录')),
    );
  }

  Future<void> _launchGame(String version, authState, GameSettings settings) async {
    if (!authState.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录账户')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
      );
      return;
    }

    if (settings.gameDirectory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请设置游戏目录')),
      );
      return;
    }

    final launcher = Dartcraft(
      version,
      settings.gameDirectory,
      javaPath: settings.javaPath.isNotEmpty ? settings.javaPath : null,
    );

    if (!launcher.isInstalled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('版本未安装，请先下载')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('正在启动 $version...')),
    );

    try {
      final process = await launcher.launch(
        username: authState.username!,
        uuid: authState.uuid!,
        accessToken: authState.accessToken!,
        jvmArguments: [
          settings.defaultJvmArg,
          settings.minJvmArg,
          ...settings.jvmArguments,
        ],
        showOutput: true,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$version 已启动')),
      );

      process.exitCode.then((code) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('游戏已退出，退出码: $code')),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('启动失败: $e')),
      );
    }
  }
}

class _MenuItem {
  final IconData icon;
  final String label;

  const _MenuItem({required this.icon, required this.label});
}
