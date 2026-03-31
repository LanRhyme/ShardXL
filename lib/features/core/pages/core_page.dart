import 'package:dartcraft/dartcraft.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/pages/auth_page.dart';
import '../providers/dartcraft_provider.dart';

class CorePage extends ConsumerStatefulWidget {
  const CorePage({super.key});

  @override
  ConsumerState<CorePage> createState() => _CorePageState();
}

class _CorePageState extends ConsumerState<CorePage> {
  String? _selectedVersion;
  bool _isGameRunning = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(gameSettingsProvider.notifier).loadSettings();
      ref.read(authProvider.notifier).loadSavedAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final installedAsync = ref.watch(installedVersionsProvider);
    final gameSettings = ref.watch(gameSettingsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '核心管理',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '管理 Minecraft 版本和模组核心',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          _buildAccountSection(authState),
          const SizedBox(height: 16),
          _buildGameDirectorySection(gameSettings),
          const SizedBox(height: 16),
          _buildVersionSelector(installedAsync),
          const SizedBox(height: 16),
          Expanded(
            child: _buildVersionDetails(),
          ),
          _buildLaunchButton(authState, gameSettings),
        ],
      ),
    );
  }

  Widget _buildAccountSection(AuthState authState) {
    if (authState.isAuthenticated) {
      return Card(
        child: ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text(authState.username ?? 'Unknown'),
          subtitle: Text(
            'UUID: ${authState.uuid ?? "N/A"}\n认证方式: ${authState.authMethod == AuthMethod.microsoft ? "Microsoft" : "Ely.by"}',
          ),
          trailing: TextButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('退出'),
          ),
          isThreeLine: true,
        ),
      );
    }

    return Card(
      child: ListTile(
        leading: const Icon(Icons.account_circle_outlined),
        title: const Text('未登录'),
        subtitle: const Text('点击登录 Minecraft 账户'),
        trailing: FilledButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AuthPage()),
            );
          },
          child: const Text('登录'),
        ),
      ),
    );
  }

  Widget _buildGameDirectorySection(GameSettings settings) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.folder),
        title: const Text('游戏目录'),
        subtitle: Text(settings.gameDirectory.isEmpty
            ? '未设置'
            : settings.gameDirectory),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _showGameDirectoryDialog(settings),
        ),
      ),
    );
  }

  Widget _buildVersionSelector(AsyncValue<List<String>> installedAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择版本',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            installedAsync.when(
              data: (versions) {
                if (versions.isEmpty) {
                  return const Text('暂无已安装的版本，请到下载页面安装');
                }
                return DropdownButtonFormField<String>(
                  value: _selectedVersion,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '选择要启动的版本',
                  ),
                  items: versions.map((v) {
                    return DropdownMenuItem(value: v, child: Text(v));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedVersion = value);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('加载失败: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionDetails() {
    if (_selectedVersion == null) {
      return const Center(
        child: Text('请选择要查看或启动的版本'),
      );
    }

    final settings = ref.watch(gameSettingsProvider);
    final launcher = Dartcraft(
      _selectedVersion!,
      settings.gameDirectory,
      javaPath: settings.javaPath.isNotEmpty ? settings.javaPath : null,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 8),
                Text(
                  _selectedVersion!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow(
              '安装状态',
              launcher.isInstalled ? '已安装' : '未安装',
              launcher.isInstalled ? Colors.green : Colors.orange,
            ),
            _buildInfoRow(
              'Java 路径',
              settings.javaPath.isEmpty ? '自动检测' : settings.javaPath,
            ),
            _buildInfoRow('内存分配', '${settings.memoryMB} MB'),
            _buildInfoRow(
              '窗口大小',
              '${settings.windowWidth} x ${settings.windowHeight}',
            ),
            if (_isGameRunning) ...[
              const Divider(),
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('游戏正在运行...'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: valueColor != null ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaunchButton(AuthState authState, GameSettings settings) {
    final canLaunch = authState.isAuthenticated &&
        _selectedVersion != null &&
        settings.gameDirectory.isNotEmpty &&
        !_isGameRunning;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: canLaunch ? () => _launchGame(authState, settings) : null,
        icon: const Icon(Icons.play_arrow),
        label: Text(_isGameRunning ? '运行中...' : '启动游戏'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  void _showGameDirectoryDialog(GameSettings settings) {
    final controller = TextEditingController(text: settings.gameDirectory);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置游戏目录'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '游戏目录路径',
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
              ref.refresh(installedVersionsProvider);
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchGame(AuthState authState, GameSettings settings) async {
    if (_selectedVersion == null || !authState.isAuthenticated) return;

    final launcher = Dartcraft(
      _selectedVersion!,
      settings.gameDirectory,
      javaPath: settings.javaPath.isNotEmpty ? settings.javaPath : null,
    );

    if (!launcher.isInstalled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('版本未安装，请先下载')),
      );
      return;
    }

    setState(() => _isGameRunning = true);

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

      setState(() => _isGameRunning = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_selectedVersion} 已启动')),
      );

      process.exitCode.then((code) {
        if (mounted) {
          setState(() => _isGameRunning = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('游戏已退出，退出码: $code')),
          );
        }
      });
    } catch (e) {
      setState(() => _isGameRunning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('启动失败: $e')),
      );
    }
  }
}
