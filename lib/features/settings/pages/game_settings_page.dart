import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../game_instance/providers/dartcraft_provider.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/shadcn_button.dart';
import '../../../core/widgets/shadcn_components.dart';
import '../../../core/theme/shard_theme.dart';

class GameSettingsPage extends ConsumerStatefulWidget {
  const GameSettingsPage({super.key});

  @override
  ConsumerState<GameSettingsPage> createState() => _GameSettingsPageState();
}

class _GameSettingsPageState extends ConsumerState<GameSettingsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(gameSettingsProvider.notifier).loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(gameSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 页面标题
          _buildHeader(context, colorScheme),
          const SizedBox(height: 20),

          // Java 设置
          _buildSettingsSection(
            context,
            colorScheme,
            themeExtension,
            title: 'Java 设置',
            icon: Icons.hub_outlined,
            children: [
              _buildSettingTile(
                context,
                colorScheme,
                themeExtension,
                icon: Icons.folder_outlined,
                title: 'Java 路径',
                subtitle: settings.javaPath.isEmpty
                    ? '自动检测'
                    : settings.javaPath,
                onTap: () => _showJavaPathDialog(settings),
              ),
              const SizedBox(height: 12),
              _buildSettingTile(
                context,
                colorScheme,
                themeExtension,
                icon: Icons.memory_outlined,
                title: '内存分配',
                subtitle: '${settings.memoryMB} MB',
                onTap: () => _showMemoryDialog(settings),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 游戏目录
          _buildSettingsSection(
            context,
            colorScheme,
            themeExtension,
            title: '游戏目录',
            icon: Icons.folder_open_outlined,
            children: [
              _buildSettingTile(
                context,
                colorScheme,
                themeExtension,
                icon: Icons.folder_outlined,
                title: '游戏目录',
                subtitle: settings.gameDirectory.isEmpty
                    ? '未设置'
                    : settings.gameDirectory,
                onTap: () => _showGameDirectoryDialog(settings),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 窗口设置
          _buildSettingsSection(
            context,
            colorScheme,
            themeExtension,
            title: '窗口设置',
            icon: Icons.aspect_ratio_outlined,
            children: [
              _buildSettingTile(
                context,
                colorScheme,
                themeExtension,
                icon: Icons.aspect_ratio_outlined,
                title: '游戏窗口',
                subtitle: settings.fullscreen
                    ? '全屏模式'
                    : '${settings.windowWidth} x ${settings.windowHeight}',
                onTap: () => _showWindowDialog(settings),
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                context,
                colorScheme,
                icon: Icons.crop_outlined,
                title: '全屏启动',
                subtitle: '游戏以全屏模式启动',
                value: settings.fullscreen,
                onChanged: (value) {
                  ref.read(gameSettingsProvider.notifier).setFullscreen(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 高级参数
          _buildSettingsSection(
            context,
            colorScheme,
            themeExtension,
            title: '高级参数',
            icon: Icons.code_outlined,
            children: [
              _buildExpandableTile(
                context,
                colorScheme,
                themeExtension,
                icon: Icons.code_outlined,
                title: 'JVM 参数',
                subtitle: settings.jvmArguments.isEmpty
                    ? '无自定义参数'
                    : settings.jvmArguments.join(' '),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '推荐参数（自动添加）：',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '-Xmx${settings.memoryMB}M -Xms${settings.memoryMB ~/ 2}M',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontFamily: 'monospace',
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '自定义参数：',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            hintText:
                                '例如: -XX:+UseG1GC -XX:+UseConcMarkSweepGC',
                            isDense: true,
                          ),
                          controller: TextEditingController(
                            text: settings.jvmArguments.join(' '),
                          ),
                          onSubmitted: (value) {
                            final args = value
                                .split(' ')
                                .where((s) => s.isNotEmpty)
                                .toList();
                            ref
                                .read(gameSettingsProvider.notifier)
                                .setJvmArguments(args);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildExpandableTile(
                context,
                colorScheme,
                themeExtension,
                icon: Icons.settings_outlined,
                title: '游戏参数',
                subtitle: settings.gameArguments.isEmpty
                    ? '无自定义参数'
                    : settings.gameArguments.join(' '),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '例如: --fancy --fast',
                        isDense: true,
                      ),
                      controller: TextEditingController(
                        text: settings.gameArguments.join(' '),
                      ),
                      onSubmitted: (value) {
                        final args = value
                            .split(' ')
                            .where((s) => s.isNotEmpty)
                            .toList();
                        ref
                            .read(gameSettingsProvider.notifier)
                            .setGameArguments(args);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '全局游戏设置',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          '配置 Java、内存、游戏目录等全局设置',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    ColorScheme colorScheme,
    ShardThemeExtension? themeExtension, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    ColorScheme colorScheme,
    ShardThemeExtension? themeExtension, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        themeExtension?.buttonBorderRadius ?? 10.0,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    ColorScheme colorScheme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
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
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildExpandableTile(
    BuildContext context,
    ColorScheme colorScheme,
    ShardThemeExtension? themeExtension, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        leading: Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        children: children,
      ),
    );
  }

  void _showJavaPathDialog(settings) {
    final controller = TextEditingController(text: settings.javaPath);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Java 路径'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('留空将自动检测 Java。手动指定时请确保路径指向 java.exe'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: '例如: C:\\Program Files\\Java\\bin\\java.exe',
              ),
            ),
            const SizedBox(height: 8),
            Text('检测到的 Java：', style: Theme.of(context).textTheme.bodySmall),
            Text(
              _detectJavaPath(),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          ShadcnButton(
            onPressed: () => Navigator.pop(context),
            variant: ShadcnButtonVariant.outline,
            child: const Text('取消'),
          ),
          ShadcnButton(
            onPressed: () {
              ref
                  .read(gameSettingsProvider.notifier)
                  .setJavaPath(controller.text);
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  String _detectJavaPath() {
    final javaHome = Platform.environment['JAVA_HOME'];
    if (javaHome != null) {
      final javaPath =
          '$javaHome${Platform.pathSeparator}bin${Platform.pathSeparator}java';
      if (Platform.isWindows) {
        return '$javaPath.exe';
      }
      return javaPath;
    }

    final pathEnv = Platform.environment['PATH'] ?? '';
    for (final dir in pathEnv.split(Platform.pathSeparator)) {
      final javaPath = '$dir${Platform.pathSeparator}java';
      if (Platform.isWindows) {
        final file = File('$javaPath.exe');
        if (file.existsSync()) return '$javaPath.exe';
      } else {
        final file = File(javaPath);
        if (file.existsSync()) return javaPath;
      }
    }

    return '未检测到 Java';
  }

  void _showMemoryDialog(settings) {
    int memoryMB = settings.memoryMB;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('内存分配'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$memoryMB MB',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Slider(
                value: memoryMB.toDouble(),
                min: 1024,
                max: 16384,
                onChanged: (value) {
                  setState(() => memoryMB = value.round());
                },
              ),
              const Text(
                '建议：不低于 1024MB，不超过系统可用内存的 50%',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            ShadcnButton(
              onPressed: () => Navigator.pop(context),
              variant: ShadcnButtonVariant.outline,
              child: const Text('取消'),
            ),
            ShadcnButton(
              onPressed: () {
                ref.read(gameSettingsProvider.notifier).setMemoryMB(memoryMB);
                Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGameDirectoryDialog(settings) {
    final controller = TextEditingController(text: settings.gameDirectory);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('游戏目录'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '例如: C:\\Users\\xxx\\AppData\\Roaming\\.minecraft',
          ),
        ),
        actions: [
          ShadcnButton(
            onPressed: () => Navigator.pop(context),
            variant: ShadcnButtonVariant.outline,
            child: const Text('取消'),
          ),
          ShadcnButton(
            onPressed: () {
              ref
                  .read(gameSettingsProvider.notifier)
                  .setGameDirectory(controller.text);
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showWindowDialog(settings) {
    int width = settings.windowWidth;
    int height = settings.windowHeight;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('窗口大小'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$width x $height'),
              const SizedBox(height: 16),
              const Text('宽度'),
              Slider(
                value: width.toDouble(),
                min: 640,
                max: 3840,
                onChanged: (value) {
                  setState(() => width = value.round());
                },
              ),
              const Text('高度'),
              Slider(
                value: height.toDouble(),
                min: 480,
                max: 2160,
                onChanged: (value) {
                  setState(() => height = value.round());
                },
              ),
            ],
          ),
          actions: [
            ShadcnButton(
              onPressed: () => Navigator.pop(context),
              variant: ShadcnButtonVariant.outline,
              child: const Text('取消'),
            ),
            ShadcnButton(
              onPressed: () {
                ref
                    .read(gameSettingsProvider.notifier)
                    .setWindowSize(width, height);
                Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
