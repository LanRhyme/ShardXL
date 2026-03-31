// ShardXL 主题设置页面
// lib/features/settings/pages/theme_settings_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/theme_provider.dart';

/// 主题设置页面
/// 提供所有主题参数的调整界面
class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(shardThemeProvider);
    final shardTheme = themeState.theme;
    final notifier = ref.read(shardThemeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('主题设置'),
        actions: [
          TextButton.icon(
            onPressed: () => notifier.resetToDefault(),
            icon: const Icon(Icons.restore),
            label: const Text('重置'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // 主题模式
          _SectionTitle(title: '主题模式'),
          SwitchListTile(
            title: const Text('深色模式'),
            subtitle: const Text('切换深色/浅色主题'),
            value: shardTheme.isDark,
            onChanged: (value) => notifier.updateIsDark(value),
          ),
          const Divider(),

          // 主色选择
          _SectionTitle(title: '主题色'),
          _ColorPicker(
            currentColor: shardTheme.primaryColor,
            onColorChanged: (color) => notifier.updatePrimaryColor(color),
          ),
          const Divider(),

          // 玻璃效果
          _SectionTitle(title: '玻璃效果'),
          SwitchListTile(
            title: const Text('启用毛玻璃'),
            subtitle: const Text('Liquid Glass 风格'),
            value: shardTheme.enableGlassEffect,
            onChanged: (value) => notifier.updateEnableGlassEffect(value),
          ),
          ListTile(
            title: const Text('卡片不透明度'),
            subtitle: Text('${(shardTheme.cardOpacity * 100).toStringAsFixed(0)}%'),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                value: shardTheme.cardOpacity,
                min: 0.15,
                max: 0.95,
                divisions: 80,
                onChanged: (value) => notifier.updateCardOpacity(value),
              ),
            ),
          ),
          const Divider(),

          // UI 参数
          _SectionTitle(title: 'UI 参数'),
          ListTile(
            title: const Text('界面缩放'),
            subtitle: Text('${shardTheme.uiScale.toStringAsFixed(2)}x'),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                value: shardTheme.uiScale,
                min: 0.85,
                max: 1.5,
                divisions: 65,
                onChanged: (value) => notifier.updateUiScale(value),
              ),
            ),
          ),
          ListTile(
            title: const Text('动画速率'),
            subtitle: Text('${shardTheme.animationSpeed.toStringAsFixed(1)}x'),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                value: shardTheme.animationSpeed,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                onChanged: (value) => notifier.updateAnimationSpeed(value),
              ),
            ),
          ),
          const Divider(),

          // 背景类型
          _SectionTitle(title: '背景类型'),
          _BackgroundTypeSelector(
            currentType: shardTheme.backgroundType,
            onTypeChanged: (type) => notifier.updateBackgroundType(type),
          ),
          if (shardTheme.backgroundType == 'image')
            _ImageBackgroundSelector(
              currentImagePath: shardTheme.backgroundImagePath,
              onImageSelected: (path) => notifier.updateBackgroundImage(path),
            ),
          const Divider(),

          // 预览卡片
          _SectionTitle(title: '效果预览'),
          const _PreviewCard(),
        ],
      ),
    );
  }
}

/// 章节标题
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

/// 颜色选择器
class _ColorPicker extends StatelessWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorChanged;

  const _ColorPicker({
    required this.currentColor,
    required this.onColorChanged,
  });

  // 预设主题色
  static const List<Color> presetColors = [
    Color(0xFF7C4DFF), // Deep Purple
    Color(0xFF6200EA), // Violet
    Color(0xFF2979FF), // Blue
    Color(0xFF00B0FF), // Light Blue
    Color(0xFF00E5FF), // Cyan
    Color(0xFF00E676), // Green
    Color(0xFF76FF03), // Lime
    Color(0xFFFFEA00), // Yellow
    Color(0xFFFF9100), // Orange
    Color(0xFFFF1744), // Red
    Color(0xFFFF4081), // Pink
    Color(0xFFE040FB), // Purple
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presetColors.map((color) {
        final isSelected = color.toARGB32() == currentColor.toARGB32();
        return GestureDetector(
          onTap: () => onColorChanged(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

/// 背景类型选择器
class _BackgroundTypeSelector extends StatelessWidget {
  final String currentType;
  final ValueChanged<String> onTypeChanged;

  const _BackgroundTypeSelector({
    required this.currentType,
    required this.onTypeChanged,
  });

  static const List<Map<String, String>> types = [
    {'value': 'solid', 'label': '纯色', 'icon': '🎨'},
    {'value': 'gradient', 'label': '渐变', 'icon': '🌈'},
    {'value': 'image', 'label': '图片', 'icon': '🖼️'},
    {'value': 'dynamic', 'label': '动态', 'icon': '✨'},
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: types.map((type) {
        final isSelected = type['value'] == currentType;
        return ChoiceChip(
          label: Text('${type['icon']} ${type['label']}'),
          selected: isSelected,
          onSelected: (_) => onTypeChanged(type['value']!),
        );
      }).toList(),
    );
  }
}

/// 预览卡片
class _PreviewCard extends ConsumerWidget {
  const _PreviewCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(shardThemeProvider);
    final shardTheme = themeState.theme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: shardTheme.enableGlassEffect
          ? colorScheme.surfaceContainerHigh.withValues(alpha: shardTheme.cardOpacity)
          : colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ShardXL 启动器',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '主题色: #${shardTheme.primaryColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '玻璃效果: ${shardTheme.enableGlassEffect ? '开启' : '关闭'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '不透明度: ${(shardTheme.cardOpacity * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {},
                    child: const Text('启动游戏'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('版本管理'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 图片背景选择器
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
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
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
        const SizedBox(height: 12),
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
                  icon: const Icon(Icons.close),
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
          icon: const Icon(Icons.add_photo_alternate),
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
            Icons.broken_image,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}