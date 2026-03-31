// ShardXL 主题设置页面
// lib/features/settings/pages/theme_settings_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/theme_provider.dart';
import '../../../core/theme/shard_theme.dart';
import '../../../core/widgets/glass_card.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(shardThemeProvider);
    final shardTheme = themeState.theme;
    final notifier = ref.read(shardThemeProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(
                '主题设置',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => notifier.resetToDefault(),
                icon: const Icon(Icons.restore, size: 18),
                label: const Text('重置'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              _buildThemeModeSection(context, shardTheme, notifier, colorScheme),
              const SizedBox(height: 16),
              _buildColorSection(context, shardTheme, notifier, colorScheme),
              const SizedBox(height: 16),
              _buildGlassSection(context, shardTheme, notifier, colorScheme),
              const SizedBox(height: 16),
              _buildUISection(context, shardTheme, notifier, colorScheme),
              const SizedBox(height: 16),
              _buildBackgroundSection(context, shardTheme, notifier, colorScheme),
              const SizedBox(height: 16),
              _buildPreviewSection(context, colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeModeSection(
    BuildContext context,
    ShardTheme shardTheme,
    ShardThemeNotifier notifier,
    ColorScheme colorScheme,
  ) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.brightness_6_rounded,
            title: '主题模式',
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          _ThemeModeSelector(
            isDark: shardTheme.isDark,
            onChanged: (value) => notifier.updateIsDark(value),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection(
    BuildContext context,
    ShardTheme shardTheme,
    ShardThemeNotifier notifier,
    ColorScheme colorScheme,
  ) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.palette_rounded,
            title: '主题色',
            color: colorScheme.primary,
          ),
          const SizedBox(height: 16),
          _ColorPicker(
            currentColor: shardTheme.primaryColor,
            onColorChanged: (color) => notifier.updatePrimaryColor(color),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassSection(
    BuildContext context,
    ShardTheme shardTheme,
    ShardThemeNotifier notifier,
    ColorScheme colorScheme,
  ) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.blur_on_rounded,
            title: '玻璃效果',
            color: colorScheme.primary,
          ),
          const SizedBox(height: 8),
          _SettingTile(
            icon: Icons.gradient_rounded,
            title: '启用毛玻璃',
            subtitle: 'Liquid Glass 风格',
            trailing: Switch(
              value: shardTheme.enableGlassEffect,
              onChanged: (value) => notifier.updateEnableGlassEffect(value),
            ),
          ),
          const Divider(height: 24),
          _SliderTile(
            icon: Icons.opacity_rounded,
            title: '卡片不透明度',
            value: shardTheme.cardOpacity,
            min: 0.15,
            max: 0.95,
            divisions: 80,
            valueFormatter: (v) => '${(v * 100).toStringAsFixed(0)}%',
            onChanged: (value) => notifier.updateCardOpacity(value),
          ),
        ],
      ),
    );
  }

  Widget _buildUISection(
    BuildContext context,
    ShardTheme shardTheme,
    ShardThemeNotifier notifier,
    ColorScheme colorScheme,
  ) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.tune_rounded,
            title: 'UI 参数',
            color: colorScheme.primary,
          ),
          const SizedBox(height: 8),
          _SliderTile(
            icon: Icons.zoom_out_map_rounded,
            title: '界面缩放',
            value: shardTheme.uiScale,
            min: 0.85,
            max: 1.5,
            divisions: 65,
            valueFormatter: (v) => '${v.toStringAsFixed(2)}x',
            onChanged: (value) => notifier.updateUiScale(value),
          ),
          const Divider(height: 24),
          _SliderTile(
            icon: Icons.speed_rounded,
            title: '动画速率',
            value: shardTheme.animationSpeed,
            min: 0.5,
            max: 2.0,
            divisions: 15,
            valueFormatter: (v) => '${v.toStringAsFixed(1)}x',
            onChanged: (value) => notifier.updateAnimationSpeed(value),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundSection(
    BuildContext context,
    ShardTheme shardTheme,
    ShardThemeNotifier notifier,
    ColorScheme colorScheme,
  ) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.wallpaper_rounded,
            title: '背景类型',
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          _BackgroundTypeSelector(
            currentType: shardTheme.backgroundType,
            onTypeChanged: (type) => notifier.updateBackgroundType(type),
          ),
          if (shardTheme.backgroundType == 'image') ...[
            const SizedBox(height: 16),
            _ImageBackgroundSelector(
              currentImagePath: shardTheme.backgroundImagePath,
              onImageSelected: (path) => notifier.updateBackgroundImage(path),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewSection(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '效果预览',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const _PreviewCard(),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }
}

class _SliderTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) valueFormatter;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.valueFormatter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 22, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyLarge)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                valueFormatter(value),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _ThemeModeSelector({
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ThemeModeOption(
              icon: Icons.light_mode_rounded,
              label: '浅色',
              isSelected: !isDark,
              onTap: () => onChanged(false),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _ThemeModeOption(
              icon: Icons.dark_mode_rounded,
              label: '深色',
              isSelected: isDark,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeModeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorChanged;

  const _ColorPicker({
    required this.currentColor,
    required this.onColorChanged,
  });

  static const List<Color> presetColors = [
    Color(0xFF7C4DFF),
    Color(0xFF6200EA),
    Color(0xFF2979FF),
    Color(0xFF00B0FF),
    Color(0xFF00E5FF),
    Color(0xFF00E676),
    Color(0xFF76FF03),
    Color(0xFFFFEA00),
    Color(0xFFFF9100),
    Color(0xFFFF1744),
    Color(0xFFFF4081),
    Color(0xFFE040FB),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: presetColors.map((color) {
            final isSelected = color.toARGB32() == currentColor.toARGB32();
            return _ColorOption(
              color: color,
              isSelected: isSelected,
              onTap: () => onColorChanged(color),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: currentColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '当前: #${currentColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: isSelected
            ? Icon(
                Icons.check_rounded,
                color: _getContrastColor(color),
                size: 22,
              )
            : null,
      ),
    );
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

class _BackgroundTypeSelector extends StatelessWidget {
  final String currentType;
  final ValueChanged<String> onTypeChanged;

  const _BackgroundTypeSelector({
    required this.currentType,
    required this.onTypeChanged,
  });

  static const List<_BackgroundType> types = [
    _BackgroundType(value: 'solid', label: '纯色', icon: Icons.color_lens_rounded),
    _BackgroundType(value: 'gradient', label: '渐变', icon: Icons.gradient_rounded),
    _BackgroundType(value: 'image', label: '图片', icon: Icons.image_rounded),
    _BackgroundType(value: 'dynamic', label: '动态', icon: Icons.auto_awesome_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        final isSelected = type.value == currentType;
        return _BackgroundTypeChip(
          type: type,
          isSelected: isSelected,
          onTap: () => onTypeChanged(type.value),
        );
      }).toList(),
    );
  }
}

class _BackgroundType {
  final String value;
  final String label;
  final IconData icon;

  const _BackgroundType({
    required this.value,
    required this.label,
    required this.icon,
  });
}

class _BackgroundTypeChip extends StatelessWidget {
  final _BackgroundType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _BackgroundTypeChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type.icon,
              size: 18,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              type.label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends ConsumerWidget {
  const _PreviewCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(shardThemeProvider);
    final shardTheme = themeState.theme;
    final colorScheme = Theme.of(context).colorScheme;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.rocket_launch_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ShardXL 启动器',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Minecraft 启动器',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _PreviewInfoRow(
                  icon: Icons.palette_rounded,
                  label: '主题色',
                  value: '#${shardTheme.primaryColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                ),
                const SizedBox(height: 8),
                _PreviewInfoRow(
                  icon: Icons.blur_on_rounded,
                  label: '玻璃效果',
                  value: shardTheme.enableGlassEffect ? '已开启' : '已关闭',
                ),
                const SizedBox(height: 8),
                _PreviewInfoRow(
                  icon: Icons.opacity_rounded,
                  label: '不透明度',
                  value: '${(shardTheme.cardOpacity * 100).toStringAsFixed(0)}%',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('启动游戏'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.inventory_2_rounded),
                  label: const Text('版本管理'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PreviewInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
        ),
      ],
    );
  }
}

class _ImageBackgroundSelector extends ConsumerStatefulWidget {
  final String? currentImagePath;
  final ValueChanged<String?> onImageSelected;

  const _ImageBackgroundSelector({
    this.currentImagePath,
    required this.onImageSelected,
  });

  @override
  ConsumerState<_ImageBackgroundSelector> createState() =>
      _ImageBackgroundSelectorState();
}

class _ImageBackgroundSelectorState
    extends ConsumerState<_ImageBackgroundSelector> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        widget.onImageSelected(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.currentImagePath != null &&
            widget.currentImagePath!.isNotEmpty) ...[
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImagePreview(),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  onPressed: () => widget.onImageSelected(null),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.errorContainer,
                    foregroundColor: colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: _showImageSourceDialog,
          icon: const Icon(Icons.add_photo_alternate_rounded),
          label: Text(widget.currentImagePath == null ||
                  widget.currentImagePath!.isEmpty
              ? '选择图片'
              : '更换图片'),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    final file = File(widget.currentImagePath!);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: double.infinity,
        height: 150,
        fit: BoxFit.cover,
      );
    }
    return Image.asset(
      widget.currentImagePath!,
      width: double.infinity,
      height: 150,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: double.infinity,
        height: 150,
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: Center(
          child: Icon(
            Icons.broken_image_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
