import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../game_instance/providers/game_provider.dart';
import '../../../core/widgets/faded_edge_scroll_view.dart';
import '../../../core/widgets/shadcn_components.dart';
import '../../../core/widgets/shadcn_button.dart';
import 'version_download_detail_page.dart';

class GameVersionListPage extends ConsumerStatefulWidget {
  const GameVersionListPage({super.key});

  @override
  ConsumerState<GameVersionListPage> createState() => _GameVersionListPageState();
}

class _GameVersionListPageState extends ConsumerState<GameVersionListPage> {
  String _selectedFilter = '全部';
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: _buildHeader(colorScheme),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildSearchAndFilter(colorScheme),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _buildVersionList(colorScheme),
        ),
      ],
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '游戏版本',
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

  Widget _buildSearchAndFilter(ColorScheme colorScheme) {
    return Column(
      children: [
        ShadcnInput(
          placeholder: '搜索版本号...',
          prefixIcon: Icons.search,
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
          suffix: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, size: 18, color: colorScheme.outline),
                  onPressed: () {
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
        ),
        const SizedBox(height: 10),
        ShadcnTabs(
          tabs: const [
            ShadcnTab(label: '全部'),
            ShadcnTab(label: '正式版'),
            ShadcnTab(label: '快照版'),
            ShadcnTab(label: '远古版'),
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
                  _selectedFilter = 'old';
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

  Widget _buildVersionList(ColorScheme colorScheme) {
    final versionsAsync = ref.watch(availableVersionsProvider);

    return versionsAsync.when(
      data: (versions) {
        final filtered = versions.where((v) {
          final matchesFilter = _selectedFilter == '全部' ||
              (_selectedFilter == 'old'
                  ? (v.versionType == 'old_beta' || v.versionType == 'old_alpha')
                  : v.versionType == _selectedFilter);
          final matchesSearch = _searchQuery.isEmpty ||
              v.id.toLowerCase().contains(_searchQuery.toLowerCase());
          return matchesFilter && matchesSearch;
        }).toList();

        if (filtered.isEmpty) {
          return _buildEmptyState(colorScheme);
        }

        return FadedEdgeWrapper(
          fadeHeight: 40,
          scrollView: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return _buildVersionCard(filtered[index]);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(colorScheme),
    );
  }

  Widget _buildVersionCard(MinecraftVersion version) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: _VersionCard(
        versionId: version.id,
        versionType: version.versionType,
        releaseTime: version.releaseTime,
        onTap: () => _navigateToDetail(version),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 56, color: colorScheme.outline.withValues(alpha: 0.4)),
          const SizedBox(height: 14),
          Text('没有找到匹配的版本', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 56, color: colorScheme.error.withValues(alpha: 0.5)),
          const SizedBox(height: 14),
          Text('加载失败', style: TextStyle(color: colorScheme.error, fontSize: 15)),
          const SizedBox(height: 12),
          ShadcnButton(
            onPressed: () => ref.refresh(availableVersionsProvider),
            icon: Icons.refresh,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(MinecraftVersion version) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => VersionDownloadDetailPage(
          version: version,
        ),
      ),
    );
  }
}

class _VersionCard extends StatefulWidget {
  final String versionId;
  final String versionType;
  final DateTime releaseTime;
  final VoidCallback onTap;

  const _VersionCard({
    required this.versionId,
    required this.versionType,
    required this.releaseTime,
    required this.onTap,
  });

  @override
  State<_VersionCard> createState() => _VersionCardState();
}

class _VersionCardState extends State<_VersionCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  String _formatReleaseTime() {
    final time = widget.releaseTime;
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _isHovered
                  ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.85)
                  : colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: _isHovered ? 0.2 : 0.1),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/icons/vanilla.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.gamepad, color: colorScheme.primary, size: 20);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.versionId,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _VersionTag(versionType: widget.versionType),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatReleaseTime(),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VersionTag extends StatelessWidget {
  final String versionType;

  const _VersionTag({required this.versionType});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    String text;
    Color bgColor;
    Color textColor;

    switch (versionType) {
      case 'release':
        bgColor = colorScheme.primary;
        textColor = colorScheme.onPrimary;
        text = '正式版';
        break;
      case 'snapshot':
        bgColor = colorScheme.secondary;
        textColor = colorScheme.onSecondary;
        text = '快照版';
        break;
      case 'old_beta':
      case 'old_alpha':
        bgColor = Colors.transparent;
        textColor = colorScheme.onSurfaceVariant;
        text = versionType == 'old_beta' ? '远古测试版' : '远古Alpha';
        break;
      default:
        bgColor = colorScheme.secondary;
        textColor = colorScheme.onSecondary;
        text = versionType;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: versionType == 'old_beta' || versionType == 'old_alpha'
            ? Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
                width: 0.5,
              )
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
