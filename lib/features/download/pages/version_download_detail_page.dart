import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../game_instance/providers/game_provider.dart';
import '../../../core/widgets/shadcn_components.dart';
import '../../../core/widgets/shadcn_button.dart';

enum LoaderCategory { modLoader, shaderPack }

enum ModLoaderType { forge, neoforge, fabric, quilt }
enum ShaderLoaderType { optifine }

enum VersionType { stable, beta, alpha, preview }
enum LoaderTag { recommended, latest }

class LoaderOption {
  final String id;
  final String name;
  final String? assetIcon;
  final IconData icon;

  const LoaderOption({
    required this.id,
    required this.name,
    this.assetIcon,
    required this.icon,
  });
}

class LoaderVersion {
  final String version;
  final String? displayName;
  final VersionType? versionType;
  final String? releaseDate;
  final String? minForgeVersion;
  final List<LoaderTag>? tags;

  const LoaderVersion({
    required this.version,
    this.displayName,
    this.versionType,
    this.releaseDate,
    this.minForgeVersion,
    this.tags,
  });

  String get display => displayName ?? version;
}

class VersionDownloadDetailPage extends ConsumerStatefulWidget {
  final MinecraftVersion version;

  const VersionDownloadDetailPage({super.key, required this.version});

  @override
  ConsumerState<VersionDownloadDetailPage> createState() => _VersionDownloadDetailPageState();
}

class _VersionDownloadDetailPageState extends ConsumerState<VersionDownloadDetailPage> {
  late TextEditingController _nameController;
  String? _selectedModLoader;
  String? _selectedShaderLoader;
  String? _selectedModLoaderVersion;
  String? _selectedShaderLoaderVersion;
  String? _selectedFabricApiVersion;
  String? _selectedQuiltApiVersion;
  bool _installFabricApi = false;
  bool _installQuiltApi = false;
  bool _isDownloading = false;

  static const _modLoaders = [
    LoaderOption(id: 'forge', name: 'Forge', icon: Icons.build, assetIcon: 'forge.png'),
    LoaderOption(id: 'neoforge', name: 'NeoForge', icon: Icons.science, assetIcon: 'neoforge.png'),
    LoaderOption(id: 'fabric', name: 'Fabric', icon: Icons.extension, assetIcon: 'fabric.png'),
    LoaderOption(id: 'quilt', name: 'Quilt', icon: Icons.grid_view, assetIcon: 'quilt.webp'),
  ];

  static const _shaderLoaders = [
    LoaderOption(id: 'optifine', name: 'OptiFine', icon: Icons.auto_awesome, assetIcon: 'optifine.png'),
  ];

  static const _forgeVersions = [
    LoaderVersion(version: '1.21.4', displayName: '1.21.4', tags: [LoaderTag.recommended, LoaderTag.latest], releaseDate: '2025-03-15 14:30'),
    LoaderVersion(version: '1.21.1', displayName: '1.21.1', releaseDate: '2025-02-20 09:15'),
    LoaderVersion(version: '1.20.6', displayName: '1.20.6', tags: [LoaderTag.recommended], releaseDate: '2025-01-10 16:45'),
    LoaderVersion(version: '1.20.4', displayName: '1.20.4', releaseDate: '2024-12-05 11:20'),
    LoaderVersion(version: '1.20.2', displayName: '1.20.2', releaseDate: '2024-11-18 08:30'),
    LoaderVersion(version: '1.19.4', displayName: '1.19.4', releaseDate: '2024-10-22 14:00'),
    LoaderVersion(version: '1.18.2', displayName: '1.18.2', releaseDate: '2024-09-01 10:45'),
    LoaderVersion(version: '1.16.5', displayName: '1.16.5', releaseDate: '2024-07-15 12:00'),
  ];

  static const _fabricVersions = [
    LoaderVersion(version: '0.16.9', displayName: '0.16.9', versionType: VersionType.stable, releaseDate: '2025-03-10 18:00'),
    LoaderVersion(version: '0.16.2', displayName: '0.16.2', versionType: VersionType.stable, releaseDate: '2025-02-28 15:30'),
    LoaderVersion(version: '0.15.11', displayName: '0.15.11', versionType: VersionType.stable, releaseDate: '2025-02-15 12:00'),
    LoaderVersion(version: '0.15.7', displayName: '0.15.7', versionType: VersionType.beta, releaseDate: '2025-01-25 09:45'),
    LoaderVersion(version: '0.15.1', displayName: '0.15.1', versionType: VersionType.beta, releaseDate: '2025-01-10 16:00'),
    LoaderVersion(version: '0.14.21', displayName: '0.14.21', versionType: VersionType.alpha, releaseDate: '2024-12-20 14:30'),
  ];

  static const _neoforgeVersions = [
    LoaderVersion(version: '21.4.45', displayName: '21.4.45', tags: [LoaderTag.recommended, LoaderTag.latest], releaseDate: '2025-03-12 20:00'),
    LoaderVersion(version: '21.1.116', displayName: '21.1.116', releaseDate: '2025-02-18 11:30'),
    LoaderVersion(version: '20.4.76', displayName: '20.4.76', tags: [LoaderTag.recommended], releaseDate: '2025-01-08 09:00'),
    LoaderVersion(version: '20.2.67', displayName: '20.2.67', releaseDate: '2024-12-01 15:45'),
    LoaderVersion(version: '18.3.72', displayName: '18.3.72', releaseDate: '2024-10-15 10:00'),
  ];

  static const _optifineVersions = [
    LoaderVersion(version: 'HD_U_I9', displayName: 'HD U I9', versionType: VersionType.preview, releaseDate: '2025-03-01 08:00', minForgeVersion: '1.20.4'),
    LoaderVersion(version: 'HD_U_I8', displayName: 'HD U I8', versionType: VersionType.preview, releaseDate: '2025-02-10 12:00', minForgeVersion: '1.20.2'),
    LoaderVersion(version: 'HD_U_I7', displayName: 'HD U I7', versionType: VersionType.stable, releaseDate: '2025-01-20 16:00', minForgeVersion: '1.20.1'),
    LoaderVersion(version: 'HD_U_I6', displayName: 'HD U I6', versionType: VersionType.stable, releaseDate: '2024-12-15 10:00', minForgeVersion: '1.19.4'),
    LoaderVersion(version: 'HD_U_I5', displayName: 'HD U I5', versionType: VersionType.stable, releaseDate: '2024-11-25 14:30', minForgeVersion: '1.19.2'),
    LoaderVersion(version: 'HD_U_I4', displayName: 'HD U I4', versionType: VersionType.stable, releaseDate: '2024-10-30 09:00', minForgeVersion: '1.18.2'),
    LoaderVersion(version: 'HD_U_I3', displayName: 'HD U I3', versionType: VersionType.stable, releaseDate: '2024-09-20 15:00', minForgeVersion: '1.16.5'),
    LoaderVersion(version: 'HD_U_I2', displayName: 'HD U I2', versionType: VersionType.stable, releaseDate: '2024-08-10 11:00', minForgeVersion: '1.16.5'),
    LoaderVersion(version: 'HD_U_I1', displayName: 'HD U I1', versionType: VersionType.stable, releaseDate: '2024-07-05 13:00', minForgeVersion: '1.16.5'),
  ];

  static const _fabricApiVersions = [
    LoaderVersion(version: '0.100.1', displayName: '0.100.1', versionType: VersionType.stable, releaseDate: '2025-03-08 12:00'),
    LoaderVersion(version: '0.100.0', displayName: '0.100.0', versionType: VersionType.beta, releaseDate: '2025-02-25 09:30'),
    LoaderVersion(version: '0.99.0', displayName: '0.99.0', versionType: VersionType.beta, releaseDate: '2025-02-10 16:00'),
    LoaderVersion(version: '0.98.0', displayName: '0.98.0', versionType: VersionType.beta, releaseDate: '2025-01-15 11:00'),
    LoaderVersion(version: '0.97.0', displayName: '0.97.0', versionType: VersionType.alpha, releaseDate: '2024-12-20 14:00'),
    LoaderVersion(version: '0.96.0', displayName: '0.96.0', versionType: VersionType.alpha, releaseDate: '2024-11-05 10:30'),
  ];

  static const _quiltApiVersions = [
    LoaderVersion(version: '0.30.0', displayName: '0.30.0', versionType: VersionType.stable, releaseDate: '2025-03-05 15:00'),
    LoaderVersion(version: '0.29.0', displayName: '0.29.0', versionType: VersionType.stable, releaseDate: '2025-02-20 11:00'),
    LoaderVersion(version: '0.28.0', displayName: '0.28.0', versionType: VersionType.beta, releaseDate: '2025-01-30 09:00'),
    LoaderVersion(version: '0.27.0', displayName: '0.27.0', versionType: VersionType.beta, releaseDate: '2024-12-15 14:00'),
    LoaderVersion(version: '0.26.0', displayName: '0.26.0', versionType: VersionType.alpha, releaseDate: '2024-11-10 16:30'),
    LoaderVersion(version: '0.25.0', displayName: '0.25.0', versionType: VersionType.alpha, releaseDate: '2024-10-01 12:00'),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.version.id);
    _selectedModLoaderVersion = _getDefaultModLoaderVersion('forge');
    _selectedShaderLoaderVersion = 'HD_U_I9';
  }

  List<LoaderVersion> _getSortedVersions(List<LoaderVersion> versions) {
    return List.from(versions)..sort((a, b) {
      if (a.tags?.contains(LoaderTag.recommended) == true && b.tags?.contains(LoaderTag.recommended) != true) return -1;
      if (b.tags?.contains(LoaderTag.recommended) == true && a.tags?.contains(LoaderTag.recommended) != true) return 1;
      if (a.tags?.contains(LoaderTag.latest) == true && b.tags?.contains(LoaderTag.latest) != true) return -1;
      if (b.tags?.contains(LoaderTag.latest) == true && a.tags?.contains(LoaderTag.latest) != true) return 1;
      return 0;
    });
  }

  String? _getDefaultModLoaderVersion(String loaderId) {
    final versions = _getModLoaderVersions(loaderId);
    if (versions.isEmpty) return null;
    final recommended = versions.where((v) => v.tags?.contains(LoaderTag.recommended) == true).toList();
    if (recommended.isNotEmpty) return recommended.first.version;
    return versions.first.version;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildDragHandle(colorScheme),
            _buildHeader(colorScheme),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding + 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVersionHeader(colorScheme),
                    const SizedBox(height: 20),
                    _buildNameEditor(colorScheme),
                    const SizedBox(height: 20),
                    _buildModLoaderSection(colorScheme),
                    const SizedBox(height: 20),
                    _buildShaderLoaderSection(colorScheme),
                    const SizedBox(height: 24),
                    _buildDownloadButton(colorScheme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle(ColorScheme colorScheme) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          ShadcnIconButton(
            icon: Icons.close,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Text(
            '版本详情',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
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
                return Icon(Icons.gamepad, color: colorScheme.primary, size: 24);
              },
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.version.id,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _VersionTag(versionType: widget.version.versionType),
                    const SizedBox(width: 8),
                    Text(
                      _formatReleaseTime(widget.version.releaseTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameEditor(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '实例名称',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        ShadcnInput(
          controller: _nameController,
          placeholder: '输入实例名称...',
          prefixIcon: Icons.edit_outlined,
        ),
      ],
    );
  }

  Widget _buildModLoaderSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.extension, size: 16, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              '模组加载器',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '（可选，支持与光影加载器同时安装）',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.9,
          ),
          itemCount: _modLoaders.length,
          itemBuilder: (context, index) {
            final loader = _modLoaders[index];
            final isSelected = _selectedModLoader == loader.id;
            return _buildLoaderCard(loader, isSelected, colorScheme, () {
              setState(() {
                if (_selectedModLoader == loader.id) {
                  _selectedModLoader = null;
                } else {
                  _selectedModLoader = loader.id;
                  _selectedModLoaderVersion = _getDefaultModLoaderVersion(loader.id);
                  if (loader.id == 'fabric') {
                    _installFabricApi = true;
                    _selectedFabricApiVersion = _fabricApiVersions.isNotEmpty
                        ? _fabricApiVersions.first.version
                        : null;
                  } else if (loader.id == 'quilt') {
                    _installQuiltApi = true;
                    _selectedQuiltApiVersion = _quiltApiVersions.isNotEmpty
                        ? _quiltApiVersions.first.version
                        : null;
                  }
                }
              });
            });
          },
        ),
        if (_selectedModLoader != null) ...[
          const SizedBox(height: 12),
          _buildVersionSelector(
            context,
            colorScheme,
            label: '选择版本',
            value: _selectedModLoaderVersion,
            versions: _getModLoaderVersions(_selectedModLoader!),
            showVersionType: _selectedModLoader == 'fabric' || _selectedModLoader == 'quilt' || _selectedModLoader == 'neoforge',
            onChanged: (v) => setState(() => _selectedModLoaderVersion = v),
          ),
          if (_selectedModLoader == 'fabric') ...[
            const SizedBox(height: 12),
            _buildApiInstaller(
              colorScheme,
              'Fabric API',
              _installFabricApi,
              _selectedFabricApiVersion,
              _fabricApiVersions,
              true,
              (v) => setState(() {
                _installFabricApi = v;
                if (v && _selectedFabricApiVersion == null) {
                  _selectedFabricApiVersion = _fabricApiVersions.isNotEmpty
                      ? _fabricApiVersions.first.version
                      : null;
                }
              }),
              (v) => setState(() => _selectedFabricApiVersion = v),
            ),
          ],
          if (_selectedModLoader == 'quilt') ...[
            const SizedBox(height: 12),
            _buildApiInstaller(
              colorScheme,
              'Quilted Fabric API',
              _installQuiltApi,
              _selectedQuiltApiVersion,
              _quiltApiVersions,
              true,
              (v) => setState(() {
                _installQuiltApi = v;
                if (v && _selectedQuiltApiVersion == null) {
                  _selectedQuiltApiVersion = _quiltApiVersions.isNotEmpty
                      ? _quiltApiVersions.first.version
                      : null;
                }
              }),
              (v) => setState(() => _selectedQuiltApiVersion = v),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildShaderLoaderSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, size: 16, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              '光影加载器',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '（可选，支持与模组加载器同时安装）',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.9,
          ),
          itemCount: _shaderLoaders.length,
          itemBuilder: (context, index) {
            final loader = _shaderLoaders[index];
            final isSelected = _selectedShaderLoader == loader.id;
            return _buildLoaderCard(loader, isSelected, colorScheme, () {
              setState(() {
                if (_selectedShaderLoader == loader.id) {
                  _selectedShaderLoader = null;
                  _selectedShaderLoaderVersion = null;
                } else {
                  _selectedShaderLoader = loader.id;
                  _selectedShaderLoaderVersion = 'HD_U_I9';
                }
              });
            });
          },
        ),
        if (_selectedShaderLoader != null) ...[
          const SizedBox(height: 12),
          _buildVersionSelector(
            context,
            colorScheme,
            label: '选择版本',
            value: _selectedShaderLoaderVersion,
            versions: _optifineVersions,
            showVersionType: true,
            showMinForge: true,
            onChanged: (v) => setState(() => _selectedShaderLoaderVersion = v),
          ),
        ],
      ],
    );
  }

  List<LoaderVersion> _getModLoaderVersions(String loaderId) {
    final versions = switch (loaderId) {
      'forge' => _forgeVersions,
      'neoforge' => _neoforgeVersions,
      'fabric' => _fabricVersions,
      'quilt' => _quiltApiVersions,
      _ => <LoaderVersion>[],
    };
    return _getSortedVersions(versions);
  }

  Widget _buildLoaderCard(LoaderOption loader, bool isSelected, ColorScheme colorScheme, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.4)
              : colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.5)
                : colorScheme.outlineVariant.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.12)
                      : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                ),
                padding: const EdgeInsets.all(4),
                child: loader.assetIcon != null
                    ? Image.asset(
                        'assets/icons/${loader.assetIcon}',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            loader.icon,
                            size: 16,
                            color: isSelected ? colorScheme.primary : colorScheme.outline,
                          );
                        },
                      )
                    : Icon(
                        loader.icon,
                        size: 16,
                        color: isSelected ? colorScheme.primary : colorScheme.outline,
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                loader.name,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionSelector(
    BuildContext context,
    ColorScheme colorScheme, {
    required String label,
    required String? value,
    required List<LoaderVersion> versions,
    required ValueChanged<String?> onChanged,
    bool showVersionType = false,
    bool showMinForge = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _showVersionPicker(context, colorScheme, versions, value, showVersionType, showMinForge, onChanged),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value ?? '请选择',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: colorScheme.outline),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVersionPicker(
    BuildContext context,
    ColorScheme colorScheme,
    List<LoaderVersion> versions,
    String? currentValue,
    bool showVersionType,
    bool showMinForge,
    ValueChanged<String?> onChanged,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '选择版本',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: versions.length,
                itemBuilder: (context, index) {
                  final v = versions[index];
                  final isSelected = v.version == currentValue;
                  return _buildVersionItem(context, colorScheme, v, isSelected, showVersionType, showMinForge, (version) {
                    onChanged(version);
                    Navigator.pop(context);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionItem(
    BuildContext context,
    ColorScheme colorScheme,
    LoaderVersion v,
    bool isSelected,
    bool showVersionType,
    bool showMinForge,
    ValueChanged<String> onTap,
  ) {
    return GestureDetector(
      onTap: () => onTap(v.version),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.3) : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        v.display,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (v.tags?.contains(LoaderTag.recommended) == true)
                        _buildTag(colorScheme, '官方推荐', colorScheme.primary),
                      if (v.tags?.contains(LoaderTag.latest) == true)
                        _buildTag(colorScheme, '最新版', colorScheme.secondary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (showVersionType && v.versionType != null)
                        _buildTypeTag(colorScheme, v.versionType!),
                      if (v.releaseDate != null)
                        Text(
                          v.releaseDate!,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.outline,
                          ),
                        ),
                      if (showMinForge && v.minForgeVersion != null)
                        Text(
                          '最低兼容 Forge: ${v.minForgeVersion}',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.outline,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check, size: 20, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(ColorScheme colorScheme, String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTypeTag(ColorScheme colorScheme, VersionType type) {
    final (text, color) = switch (type) {
      VersionType.stable => ('稳定版', Colors.green),
      VersionType.beta => ('测试版', Colors.orange),
      VersionType.alpha => ('预览版', Colors.purple),
      VersionType.preview => ('预览版', Colors.purple),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildApiInstaller(
    ColorScheme colorScheme,
    String apiName,
    bool isEnabled,
    String? selectedVersion,
    List<LoaderVersion> versions,
    bool showVersionType,
    ValueChanged<bool> onEnabledChanged,
    ValueChanged<String?> onVersionChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isEnabled,
                  onChanged: (v) => onEnabledChanged(v ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  side: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '同时安装 $apiName',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (isEnabled) ...[
            const SizedBox(height: 10),
            _buildVersionSelector(
              context,
              colorScheme,
              label: 'API 版本',
              value: selectedVersion,
              versions: versions,
              showVersionType: showVersionType,
              onChanged: onVersionChanged,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDownloadButton(ColorScheme colorScheme) {
    final hasLoader = _selectedModLoader != null || _selectedShaderLoader != null;

    return SizedBox(
      width: double.infinity,
      child: ShadcnButton(
        onPressed: _isDownloading ? null : _startDownload,
        size: ShadcnButtonSize.lg,
        loading: _isDownloading,
        icon: Icons.download_rounded,
        child: Text(_isDownloading ? '下载中...' : '开始下载${hasLoader ? '' : '（原版）'}'),
      ),
    );
  }

  void _startDownload() async {
    final settings = ref.read(gameSettingsProvider);
    if (settings.gameDirectory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先在设置中配置游戏目录')),
      );
      return;
    }

    setState(() => _isDownloading = true);

    try {
      final instanceName = _nameController.text.trim().isEmpty
          ? widget.version.id
          : _nameController.text.trim();

      final parts = <String>[];
      if (_selectedModLoader != null) {
        final loaderName = switch (_selectedModLoader) {
          'forge' => 'Forge $_selectedModLoaderVersion',
          'neoforge' => 'NeoForge $_selectedModLoaderVersion',
          'fabric' => 'Fabric $_selectedModLoaderVersion${_installFabricApi ? ' + Fabric API $_selectedFabricApiVersion' : ''}',
          'quilt' => 'Quilt $_selectedModLoaderVersion${_installQuiltApi ? ' + Quilted Fabric API $_selectedQuiltApiVersion' : ''}',
          _ => 'Mod Loader',
        };
        parts.add(loaderName);
      }
      if (_selectedShaderLoader != null) {
        parts.add('OptiFine $_selectedShaderLoaderVersion');
      }

      final info = parts.isNotEmpty ? ' (${parts.join(', ')})' : '（原版）';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('正在下载 $instanceName$info...'), duration: const Duration(seconds: 3)),
        );
      }

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ref.invalidate(installedVersionsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$instanceName 下载完成（ShardXL-Lib 集成中）')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('下载失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  String _formatReleaseTime(DateTime time) {
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';
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
