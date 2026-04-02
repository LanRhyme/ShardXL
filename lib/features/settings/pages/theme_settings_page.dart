// ShardXL 主题设置页面（shadcn-ui 风格）
// lib/features/settings/pages/theme_settings_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/theme_provider.dart';
import '../../../core/theme/shard_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/shadcn_button.dart';
import '../../../core/widgets/shadcn_components.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(shardThemeProvider);
    final shardTheme = themeState.theme;
    final notifier = ref.read(shardThemeProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 页面标题
          _buildHeader(context, colorScheme, notifier),
          const SizedBox(height: 20),
          
          // 主题模式
          _buildThemeModeSection(context, shardTheme, notifier, colorScheme),
          const SizedBox(height: 16),
          
          // 主题色
          _buildColorSection(context, shardTheme, notifier, colorScheme),
          const SizedBox(height: 16),
          
          // 玻璃效果
          _buildGlassSection(context, shardTheme, notifier, colorScheme),
          const SizedBox(height: 16),
          
          // UI 参数
          _buildUISection(context, shardTheme, notifier, colorScheme),
          const SizedBox(height: 16),
          
          // 背景类型
          _buildBackgroundSection(context, shardTheme, notifier, colorScheme),
          const SizedBox(height: 16),
          
          // 效果预览
          _buildPreviewSection(context, colorScheme, shardTheme),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme, ShardThemeNotifier notifier) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '主题设置',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '自定义启动器的外观和感觉',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        ShadcnButton(
          onPressed: () => notifier.resetToDefault(),
          variant: ShadcnButtonVariant.outline,
          size: ShadcnButtonSize.sm,
          icon: Icons.restore,
          child: const Text('重置'),
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
    return _SettingsSection(
      title: '主题模式',
      icon: Icons.brightness_6_outlined,
      child: _ThemeModeSelector(
        isDark: shardTheme.isDark,
        onChanged: (value) => notifier.updateIsDark(value),
      ),
    );
  }

  Widget _buildColorSection(
    BuildContext context,
    ShardTheme shardTheme,
    ShardThemeNotifier notifier,
    ColorScheme colorScheme,
  ) {
    return _SettingsSection(
      title: '主题色',
      icon: Icons.palette_outlined,
      child: _ColorPicker(
        currentColor: shardTheme.primaryColor,
        onColorChanged: (color) => notifier.updatePrimaryColor(color),
      ),
    );
  }

  Widget _buildGlassSection(
    BuildContext context,
    ShardTheme shardTheme,
    ShardThemeNotifier notifier,
    ColorScheme colorScheme,
  ) {
    return _SettingsSection(
      title: '玻璃效果',
      icon: Icons.blur_on_outlined,
      child: Column(
        children: [
          _SettingSwitch(
            icon: Icons.grain_outlined,
            title: '启用毛玻璃',
            subtitle: 'Liquid Glass 风格',
            value: shardTheme.enableGlassEffect,
            onChanged: (value) => notifier.updateEnableGlassEffect(value),
          ),
          if (shardTheme.enableGlassEffect) ...[
            const SizedBox(height: 16),
            _SettingSlider(
              icon: Icons.opacity_outlined,
              title: '卡片不透明度',
              value: shardTheme.cardOpacity,
              min: 0.15,
              max: 0.95,
              divisions: 80,
              valueFormatter: (v) => '${(v * 100).toStringAsFixed(0)}%',
              onChanged: (value) => notifier.updateCardOpacity(value),
            ),
          ],
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
    return _SettingsSection(
      title: 'UI 参数',
      icon: Icons.tune_outlined,
      child: Column(
        children: [
          _SettingSlider(
            icon: Icons.maximize_outlined,
            title: '界面缩放',
            value: shardTheme.uiScale,
            min: 0.85,
            max: 1.5,
            divisions: 65,
            valueFormatter: (v) => '${v.toStringAsFixed(2)}x',
            onChanged: (value) => notifier.updateUiScale(value),
          ),
          const SizedBox(height: 16),
          _SettingSlider(
            icon: Icons.animation_outlined,
            title: '动画速率',
            value: shardTheme.animationSpeed,
            min: 0.5,
            max: 2.0,
            divisions: 15,
            valueFormatter: (v) => '${v.toStringAsFixed(1)}x',
            onChanged: (value) => notifier.updateAnimationSpeed(value),
          ),
          const SizedBox(height: 16),
          _SettingSlider(
            icon: Icons.rounded_corner_outlined,
            title: '圆角大小',
            value: shardTheme.borderRadius,
            min: 4.0,
            max: 20.0,
            divisions: 16,
            valueFormatter: (v) => '${v.toStringAsFixed(0)}px',
            onChanged: (value) => notifier.updateBorderRadius(value),
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
    return _SettingsSection(
      title: '背景类型',
      icon: Icons.wallpaper_outlined,
      child: Column(
        children: [
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

  Widget _buildPreviewSection(BuildContext context, ColorScheme colorScheme, ShardTheme shardTheme) {
    return _SettingsSection(
      title: '效果预览',
      icon: Icons.visibility_outlined,
      child: const _PreviewCard(),
    );
  }
}

// ========================
// 设置区域组件
// ========================

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    themeExtension?.buttonBorderRadius ?? 10.0,
                  ),
                ),
                child: Icon(icon, size: 18, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ========================
// 设置项组件
// ========================

class _SettingSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SettingSlider extends StatelessWidget {
  final IconData icon;
  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) valueFormatter;
  final ValueChanged<double> onChanged;

  const _SettingSlider({
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
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();

    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(
                  themeExtension?.buttonBorderRadius ?? 10.0,
                ),
              ),
              child: Text(
                valueFormatter(value),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
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

// ========================
// 主题模式选择器
// ========================

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
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(
          themeExtension?.buttonBorderRadius ?? 10.0,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ThemeModeOption(
              icon: Icons.wb_sunny_outlined,
              label: '浅色',
              isSelected: !isDark,
              onTap: () => onChanged(false),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _ThemeModeOption(
              icon: Icons.dark_mode_outlined,
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
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(
            themeExtension?.buttonBorderRadius ?? 10.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
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

// ========================
// 颜色选择器
// ========================

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
    final colorScheme = Theme.of(context).colorScheme;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();

    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presetColors.map((color) {
            final isSelected = color.toARGB32() == currentColor.toARGB32();
            return _ColorOption(
              color: color,
              isSelected: isSelected,
              onTap: () => onColorChanged(color),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(
              themeExtension?.buttonBorderRadius ?? 10.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: currentColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '当前: #${currentColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? Icon(
                Icons.check_rounded,
                color: _getContrastColor(color),
                size: 18,
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

// ========================
// 背景类型选择器
// ========================

class _BackgroundTypeSelector extends StatelessWidget {
  final String currentType;
  final ValueChanged<String> onTypeChanged;

  const _BackgroundTypeSelector({
    required this.currentType,
    required this.onTypeChanged,
  });

  static const List<_BackgroundType> types = [
    _BackgroundType(value: 'solid', label: '纯色', icon: Icons.color_lens_outlined),
    _BackgroundType(value: 'gradient', label: '渐变', icon: Icons.gradient_outlined),
    _BackgroundType(value: 'image', label: '图片', icon: Icons.image_outlined),
    _BackgroundType(value: 'dynamic', label: '动态', icon: Icons.auto_awesome_outlined),
    _BackgroundType(value: 'mica', label: 'Mica', icon: Icons.layers_outlined),
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
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(
            themeExtension?.buttonBorderRadius ?? 10.0,
          ),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type.icon,
              size: 16,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              type.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
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

// ========================
// 图片背景选择器
// ========================

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
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.currentImagePath != null &&
            widget.currentImagePath!.isNotEmpty) ...[
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  themeExtension?.cardBorderRadius ?? 10.0,
                ),
                child: Image.file(
                  File(widget.currentImagePath!),
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => widget.onImageSelected(null),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: ShadcnButton(
            onPressed: _showImageSourceDialog,
            variant: ShadcnButtonVariant.outline,
            icon: Icons.image_rounded,
            child: Text(widget.currentImagePath != null ? '更换图片' : '选择图片'),
          ),
        ),
      ],
    );
  }
}

// ========================
// 预览卡片
// ========================

class _PreviewCard extends ConsumerWidget {
  const _PreviewCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(shardThemeProvider);
    final shardTheme = themeState.theme;
    final colorScheme = Theme.of(context).colorScheme;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();

    return Column(
      children: [
        // 预览信息
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(
              themeExtension?.buttonBorderRadius ?? 10.0,
            ),
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
              const SizedBox(height: 8),
              _PreviewInfoRow(
                icon: Icons.rounded_corner_rounded,
                label: '圆角',
                value: '${shardTheme.borderRadius.toStringAsFixed(0)}px',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // 按钮预览
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
      ],
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
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace',
              ),
        ),
      ],
    );
  }
}