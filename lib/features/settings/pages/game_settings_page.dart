import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/dartcraft_provider.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('全局游戏设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Java 路径'),
              subtitle: Text(
                settings.javaPath.isEmpty ? '自动检测' : settings.javaPath,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showJavaPathDialog(settings),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.memory),
              title: const Text('内存分配'),
              subtitle: Text('${settings.memoryMB} MB'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showMemoryDialog(settings),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('游戏目录'),
              subtitle: Text(
                settings.gameDirectory.isEmpty
                    ? '未设置'
                    : settings.gameDirectory,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showGameDirectoryDialog(settings),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.aspect_ratio),
              title: const Text('游戏窗口'),
              subtitle: Text(
                settings.fullscreen
                    ? '全屏模式'
                    : '${settings.windowWidth} x ${settings.windowHeight}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showWindowDialog(settings),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.fullscreen),
              title: const Text('全屏启动'),
              subtitle: const Text('游戏以全屏模式启动'),
              value: settings.fullscreen,
              onChanged: (value) {
                ref.read(gameSettingsProvider.notifier).setFullscreen(value);
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.terminal),
              title: const Text('JVM 参数'),
              subtitle: Text(settings.jvmArguments.isEmpty
                  ? '无自定义参数'
                  : settings.jvmArguments.join(' ')),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '推荐参数（自动添加）：',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '-Xmx${settings.memoryMB}M -Xms${settings.memoryMB ~/ 2}M',
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '自定义参数：',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '例如: -XX:+UseG1GC -XX:+UseConcMarkSweepGC',
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
          ),
          const SizedBox(height: 8),
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.settings),
              title: const Text('游戏参数'),
              subtitle: Text(settings.gameArguments.isEmpty
                  ? '无自定义参数'
                  : settings.gameArguments.join(' ')),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '例如: --fancy --fast',
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
          ),
        ],
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
            const Text(
              '留空将自动检测 Java。手动指定时请确保路径指向 java.exe',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '例如: C:\\Program Files\\Java\\bin\\java.exe',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '检测到的 Java：',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              _detectJavaPath(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
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
      final javaPath = '$javaHome${Platform.pathSeparator}bin${Platform.pathSeparator}java';
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
                divisions: 15,
                label: '$memoryMB MB',
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton(
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
            border: OutlineInputBorder(),
            hintText: '例如: C:\\Users\\xxx\\AppData\\Roaming\\.minecraft',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
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
                divisions: 30,
                label: '$width',
                onChanged: (value) {
                  setState(() => width = value.round());
                },
              ),
              const Text('高度'),
              Slider(
                value: height.toDouble(),
                min: 480,
                max: 2160,
                divisions: 20,
                label: '$height',
                onChanged: (value) {
                  setState(() => height = value.round());
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton(
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
