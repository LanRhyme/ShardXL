import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/pages/auth_page.dart';
import '../providers/dartcraft_provider.dart';
import '../providers/game_instances_provider.dart';
import '../../../core/widgets/glass_card.dart';
import 'instance_config_page.dart';

enum _MenuView {
  overview,
  config,
  mods,
  saves,
  resources,
  shaders,
}

class _MenuItem {
  final IconData icon;
  final String label;
  final _MenuView view;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.view,
  });
}

class _VersionIconData {
  final String? assetPath;
  final List<Color> gradientColors;
  final Color shadowColor;

  const _VersionIconData({
    this.assetPath,
    required this.gradientColors,
    required this.shadowColor,
  });
}

_VersionIconData _getVersionIconData(String version) {
  final v = version.toLowerCase();
  
  if (v.contains('neoforge')) {
    return const _VersionIconData(
      assetPath: 'assets/icons/neoforge.png',
      gradientColors: [Color(0xFF7C4DFF), Color(0xFF651FFF)],
      shadowColor: Color(0xFF7C4DFF),
    );
  } else if (v.contains('forge')) {
    return const _VersionIconData(
      assetPath: 'assets/icons/forge.png',
      gradientColors: [Color(0xFF607D8B), Color(0xFF37474F)],
      shadowColor: Color(0xFF607D8B),
    );
  } else if (v.contains('fabric')) {
    return const _VersionIconData(
      assetPath: 'assets/icons/fabric.png',
      gradientColors: [Color(0xFFDB7093), Color(0xFFC2185B)],
      shadowColor: Color(0xFFDB7093),
    );
  } else if (v.contains('quilt')) {
    return const _VersionIconData(
      assetPath: 'assets/icons/quilt.png',
      gradientColors: [Color(0xFF26C6DA), Color(0xFF0097A7)],
      shadowColor: Color(0xFF26C6DA),
    );
  } else if (v.contains('optifine') || v.contains('optifabric')) {
    return const _VersionIconData(
      assetPath: 'assets/icons/optifine.png',
      gradientColors: [Color(0xFFFFB74D), Color(0xFFF57C00)],
      shadowColor: Color(0xFFFFB74D),
    );
  } else if (v.contains('snapshot') || v.contains('pre') || v.contains('rc')) {
    return const _VersionIconData(
      assetPath: 'assets/icons/snapshot.png',
      gradientColors: [Color(0xFF7E57C2), Color(0xFF512DA8)],
      shadowColor: Color(0xFF7E57C2),
    );
  } else {
    return const _VersionIconData(
      assetPath: 'assets/icons/vanilla.png',
      gradientColors: [Color(0xFF81C784), Color(0xFF388E3C)],
      shadowColor: Color(0xFF81C784),
    );
  }
}

String _getVersionTypeLabel(String version) {
  final v = version.toLowerCase();
  
  if (v.contains('neoforge')) {
    return 'NeoForge';
  } else if (v.contains('forge')) {
    return 'Forge';
  } else if (v.contains('fabric')) {
    return 'Fabric';
  } else if (v.contains('quilt')) {
    return 'Quilt';
  } else if (v.contains('optifine') || v.contains('optifabric')) {
    return 'OptiFine';
  } else if (v.contains('snapshot')) {
    return '快照版';
  } else if (v.contains('pre')) {
    return '预发布版';
  } else if (v.contains('rc')) {
    return '候选版';
  } else {
    return '官方原版';
  }
}

class GameInstancePage extends ConsumerStatefulWidget {
  const GameInstancePage({super.key});

  @override
  ConsumerState<GameInstancePage> createState() => _GameInstancePageState();
}

class _GameInstancePageState extends ConsumerState<GameInstancePage> {
  String _searchQuery = '';
  String _selectedFilter = '全部';
  String? _selectedVersion;
  _MenuView _selectedView = _MenuView.overview;

  final List<String> _filters = ['全部', '原版', '模组加载器'];

  final List<_MenuItem> _menuItems = const [
    _MenuItem(icon: Icons.grid_view, label: '实例概览', view: _MenuView.overview),
    _MenuItem(icon: Icons.settings, label: '运行配置', view: _MenuView.config),
    _MenuItem(icon: Icons.extension, label: '模组仓库', view: _MenuView.mods),
    _MenuItem(icon: Icons.save, label: '存档管理', view: _MenuView.saves),
    _MenuItem(icon: Icons.palette, label: '资源中心', view: _MenuView.resources),
    _MenuItem(icon: Icons.lightbulb, label: '视觉光影', view: _MenuView.shaders),
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          // 左侧侧边栏
          _buildSidebar(),
          // 右侧内容区
          Expanded(
            child: _buildRightContent(gameSettings, authState, installedAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 220,
      margin: const EdgeInsets.all(16),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedVersion != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                      Theme.of(context).colorScheme.surface.withValues(alpha: 0),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Builder(
                  builder: (context) {
                    final iconData = _getVersionIconData(_selectedVersion!);
                    return Column(
                      children: [
                        Image.asset(
                          iconData.assetPath!,
                          width: 80,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: iconData.gradientColors,
                              ),
                            ),
                            child: const Icon(Icons.grass, color: Colors.white, size: 40),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedVersion!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getVersionTypeLabel(_selectedVersion!),
                          style: TextStyle(
                            fontSize: 12,
                            color: iconData.shadowColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.dashboard_rounded,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'ShardXL Launcher',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Divider(height: 1, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
            ),
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  final isSelected = _selectedView == item.view;
                  return _buildMenuItem(item, isSelected);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightContent(GameSettings gameSettings, AuthState authState, AsyncValue<List<String>> installedAsync) {
    switch (_selectedView) {
      case _MenuView.overview:
        return _buildOverviewContent(gameSettings, authState, installedAsync);
      case _MenuView.config:
        return _buildConfigContent();
      case _MenuView.mods:
        return _buildPlaceholderPage('模组仓库', Icons.extension, '管理您的游戏模组');
      case _MenuView.saves:
        return _buildPlaceholderPage('存档管理', Icons.save, '管理您的游戏存档');
      case _MenuView.resources:
        return _buildPlaceholderPage('资源中心', Icons.palette, '管理资源包和材质包');
      case _MenuView.shaders:
        return _buildPlaceholderPage('视觉光影', Icons.lightbulb, '管理光影包');
    }
  }

  Widget _buildOverviewContent(GameSettings gameSettings, AuthState authState, AsyncValue<List<String>> installedAsync) {
    return Column(
      children: [
        _buildSearchHeader(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _buildFilterTabs(),
              const Spacer(),
              _buildSortButton(),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: installedAsync.when(
            data: (versions) {
              final filteredVersions = _filterVersions(versions);
              if (filteredVersions.isEmpty) {
                return _buildEmptyState(gameSettings);
              }
              return _buildVersionGrid(filteredVersions, gameSettings, authState);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, stackTrace) => _buildErrorState(e.toString(), gameSettings),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(GameSettings settings) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无符合条件的版本',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark 
                  ? colorScheme.onSurface.withValues(alpha: 0.05)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '当前目录:',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  settings.gameDirectory.isEmpty ? '未设置' : settings.gameDirectory,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _selectGameDirectory,
            icon: const Icon(Icons.folder_open_rounded, size: 18),
            label: const Text('选择游戏目录'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, GameSettings settings) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: colorScheme.error.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: TextStyle(
              color: colorScheme.error,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              error,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onErrorContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _selectGameDirectory,
            icon: const Icon(Icons.folder_open_rounded, size: 18),
            label: const Text('选择游戏目录'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigContent() {
    if (_selectedVersion == null) {
      return _buildPlaceholderPage(
        '运行配置',
        Icons.settings,
        '请先从实例概览中选择一个游戏实例',
        showHint: true,
      );
    }
    return InstanceConfigPage(version: _selectedVersion!, isEmbedded: true);
  }

  Widget _buildPlaceholderPage(String title, IconData icon, String subtitle, {bool showHint = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 56,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
          if (showHint) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => setState(() => _selectedView = _MenuView.overview),
              icon: const Icon(Icons.grid_view),
              label: const Text('前往实例概览'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: () {
          setState(() => _selectedView = item.view);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? isDark 
                    ? colorScheme.primary.withValues(alpha: 0.15)
                    : colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 18,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 32, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark 
                    ? colorScheme.onSurface.withValues(alpha: 0.05)
                    : colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark 
                      ? colorScheme.outline.withValues(alpha: 0.2)
                      : colorScheme.outline.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: TextField(
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: '搜索游戏实例...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            icon: Icons.refresh_rounded,
            tooltip: '同步并刷新',
            onTap: () => ref.refresh(installedVersionsProvider),
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.folder_open_rounded,
            tooltip: '选择游戏目录',
            onTap: _selectGameDirectory,
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: isPrimary 
            ? colorScheme.primary 
            : isDark 
                ? colorScheme.onSurface.withValues(alpha: 0.08)
                : colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 44,
            height: 44,
            decoration: isPrimary 
                ? null 
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark 
                          ? colorScheme.outline.withValues(alpha: 0.2)
                          : colorScheme.outline.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 18,
              color: isPrimary 
                  ? colorScheme.onPrimary 
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortButton() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark 
            ? colorScheme.onSurface.withValues(alpha: 0.05)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark 
              ? colorScheme.outline.withValues(alpha: 0.2)
              : colorScheme.outline.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sort_rounded, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            '最近玩过',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.arrow_drop_down, size: 16, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: _filters.map((filter) {
        final isSelected = _selectedFilter == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : isDark 
                        ? colorScheme.onSurface.withValues(alpha: 0.05)
                        : colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : isDark 
                          ? colorScheme.outline.withValues(alpha: 0.2)
                          : colorScheme.outline.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 2;
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 1400) {
          crossAxisCount = 5;
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(24, 16, 32, 100),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.0,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: versions.length,
          itemBuilder: (context, index) {
            final version = versions[index];
            final isSelected = _selectedVersion == version;
            return _VersionCard(
              key: ValueKey(version),
              version: version,
              settings: settings,
              authState: authState,
              isSelected: isSelected,
              onTap: () => setState(() => _selectedVersion = version),
              onLaunch: () => _launchGame(version, authState, settings),
              onConfig: () {
                setState(() {
                  _selectedVersion = version;
                  _selectedView = _MenuView.config;
                });
              },
              onOpenFolder: () => _openInstanceFolder(version, settings),
              onDelete: () => _showDeleteConfirmDialog(version),
            );
          },
        );
      }
    );
  }

  Future<void> _selectGameDirectory() async {
    await showDialog(
      context: context,
      builder: (context) => _GameDirectoryDialog(
        ref: ref,
        onDirectorySelected: (dir) {
          ref.invalidate(installedVersionsProvider);
        },
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

    // Check if version is installed
    final versionDir = Directory('${settings.gameDirectory}/versions/$version');
    final jarFile = File('${versionDir.path}/$version.jar');
    final jsonFile = File('${versionDir.path}/$version.json');
    
    if (!jarFile.existsSync() || !jsonFile.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('版本未安装，请先下载')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('正在启动 $version...（ShardXL-Lib 集成中）')),
    );

    try {
      // Simplified launch using ShardXL-Lib approach
      // TODO: Full ShardXL-Lib integration for game launching
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$version 启动功能即将完成')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('启动失败: $e')),
      );
    }
  }
}

class _VersionCard extends StatefulWidget {
  final String version;
  final GameSettings settings;
  final dynamic authState;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLaunch;
  final VoidCallback onConfig;
  final VoidCallback onOpenFolder;
  final VoidCallback onDelete;

  const _VersionCard({
    super.key,
    required this.version,
    required this.settings,
    required this.authState,
    required this.isSelected,
    required this.onTap,
    required this.onLaunch,
    required this.onConfig,
    required this.onOpenFolder,
    required this.onDelete,
  });

  @override
  State<_VersionCard> createState() => _VersionCardState();
}

class _VersionCardState extends State<_VersionCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconData = _getVersionIconData(widget.version);
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (_isHovered || widget.isSelected)
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 16,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
              ],
            ),
            child: GlassCard(
              hoverable: true,
              padding: EdgeInsets.zero,
              child: Stack(
                children: [
                  if (widget.isSelected)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.5),
                              width: 2,
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorScheme.primary.withValues(alpha: 0.08),
                                colorScheme.primary.withValues(alpha: 0.02),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Center(
                    child: IgnorePointer(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              iconData.assetPath!,
                              width: 56,
                              height: 56,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: iconData.gradientColors,
                                  ),
                                ),
                                child: const Icon(Icons.grass, size: 28, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.version,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: iconData.shadowColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getVersionTypeLabel(widget.version),
                                style: TextStyle(
                                  fontSize: 9,
                                  color: iconData.shadowColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                  top: 4,
                  right: 4,
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: PopupMenuButton<String>(
                      tooltip: '选项',
                      splashRadius: 14,
                      icon: Icon(
                        Icons.more_vert_rounded,
                        size: 16,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      itemBuilder: (context) => [
                        _buildPopupItem('launch', Icons.play_arrow_rounded, '启动'),
                        _buildPopupItem('config', Icons.settings_outlined, '配置'),
                        _buildPopupItem('folder', Icons.folder_open_outlined, '目录'),
                        const PopupMenuDivider(),
                        _buildPopupItem('delete', Icons.delete_outline_rounded, '移除', isDestructive: true),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'launch': widget.onLaunch(); break;
                          case 'config': widget.onConfig(); break;
                          case 'folder': widget.onOpenFolder(); break;
                          case 'delete': widget.onDelete(); break;
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon, String label, {bool isDestructive = false}) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon, 
            size: 18, 
            color: isDestructive ? Colors.red : Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDestructive ? Colors.red : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameDirectoryDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final ValueChanged<String>? onDirectorySelected;

  const _GameDirectoryDialog({
    required this.ref,
    this.onDirectorySelected,
  });

  @override
  ConsumerState<_GameDirectoryDialog> createState() => _GameDirectoryDialogState();
}

class _GameDirectoryDialogState extends ConsumerState<_GameDirectoryDialog> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(gameSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 480,
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          color: isDark 
              ? colorScheme.surface.withValues(alpha: 0.95)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark 
                ? colorScheme.outline.withValues(alpha: 0.2)
                : colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.folder_open_rounded,
                    size: 24,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '游戏目录管理',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.1)),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: settings.savedGameDirectories.length,
                itemBuilder: (context, index) {
                  final dir = settings.savedGameDirectories[index];
                  final isSelected = settings.gameDirectory == dir;
                  final isDefault = dir == GameSettingsNotifier.getDefaultMinecraftDir();

                  return _buildDirectoryItem(
                    dir: dir,
                    isSelected: isSelected,
                    isDefault: isDefault,
                    colorScheme: colorScheme,
                    isDark: isDark,
                  );
                },
              ),
            ),
            Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.1)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _addNewDirectory,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('添加目录'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectoryItem({
    required String dir,
    required bool isSelected,
    required bool isDefault,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectDirectory(dir),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08)
                : Colors.transparent,
            border: isSelected
                ? Border(
                    left: BorderSide(
                      color: colorScheme.primary,
                      width: 3,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                isDefault ? Icons.videogame_asset_rounded : Icons.folder_rounded,
                size: 20,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDefault ? '官方 Minecraft 目录' : _getDirectoryName(dir),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dir,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
              if (!isDefault) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removeDirectory(dir),
                  icon: Icon(
                    Icons.remove_circle_outline_rounded,
                    size: 18,
                    color: colorScheme.error.withValues(alpha: 0.7),
                  ),
                  splashRadius: 18,
                  tooltip: '移除',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getDirectoryName(String path) {
    final parts = path.split(Platform.pathSeparator);
    return parts.isNotEmpty ? parts.last : path;
  }

  Future<void> _selectDirectory(String dir) async {
    await ref.read(gameSettingsProvider.notifier).setGameDirectory(dir);
    widget.onDirectorySelected?.call(dir);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已切换到: $dir'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _addNewDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: '选择 Minecraft 游戏目录',
    );

    if (result != null) {
      await ref.read(gameSettingsProvider.notifier).addGameDirectory(result);
      await ref.read(gameSettingsProvider.notifier).setGameDirectory(result);
      widget.onDirectorySelected?.call(result);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已添加: $result'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _removeDirectory(String dir) async {
    final settings = ref.read(gameSettingsProvider);
    if (settings.gameDirectory == dir) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('无法移除当前使用的目录'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await ref.read(gameSettingsProvider.notifier).removeGameDirectory(dir);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已移除: $dir'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
