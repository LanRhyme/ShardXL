import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/glass_card.dart';
import '../providers/dartcraft_provider.dart';
import '../providers/instance_config_provider.dart';

class InstanceConfigPage extends ConsumerStatefulWidget {
  final String version;

  const InstanceConfigPage({
    super.key,
    required this.version,
  });

  @override
  ConsumerState<InstanceConfigPage> createState() => _InstanceConfigPageState();
}

class _InstanceConfigPageState extends ConsumerState<InstanceConfigPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(gameSettingsProvider.notifier).loadSettings();
      ref.read(instanceConfigProvider.notifier).loadConfig(widget.version);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(gameSettingsProvider);
    final config = ref.watch(instanceConfigProvider);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 返回按钮和标题
            _buildHeader(),
            const SizedBox(height: 24),
            // 版本信息卡片
            _buildVersionInfoCard(),
            const SizedBox(height: 24),
            // 配置内容
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左侧配置列表
                  Expanded(
                    flex: 3,
                    child: _buildConfigList(settings, config),
                  ),
                  const SizedBox(width: 24),
                  // 右侧快速操作
                  Expanded(
                    flex: 1,
                    child: _buildQuickActions(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: '返回',
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '运行配置',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              widget.version,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVersionInfoCard() {
    final isModded = widget.version.toLowerCase().contains('forge') ||
                     widget.version.toLowerCase().contains('fabric') ||
                     widget.version.toLowerCase().contains('quilt') ||
                     widget.version.toLowerCase().contains('neoforge');

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // 草方块图标
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF5D8C38), // 草绿色
                    const Color(0xFF8B7355), // 泥土色
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
                child: Icon(
                  Icons.grass,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.version,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isModded
                              ? Colors.orange.withOpacity(0.2)
                              : Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isModded ? '模组加载器' : '原版',
                          style: TextStyle(
                            fontSize: 12,
                            color: isModded ? Colors.orange : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green.withOpacity(0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '已安装',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () {
                // TODO: 启动游戏
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('启动游戏'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigList(GameSettings settings, InstanceConfig config) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 版本设置
          _buildSectionTitle('版本设置'),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              children: [
                _buildDropdownTile(
                  icon: Icons.folder_copy,
                  title: '版本隔离',
                  subtitle: '为此版本创建独立的游戏目录',
                  value: config.versionIsolation ? '启用' : '禁用',
                  options: const ['启用', '禁用'],
                  onChanged: (value) {
                    ref.read(instanceConfigProvider.notifier)
                        .setVersionIsolation(value == '启用');
                  },
                ),
                const Divider(height: 1),
                _buildDropdownTile(
                  icon: Icons.verified,
                  title: '游戏完整性检查',
                  subtitle: '启动前检查文件完整性',
                  value: config.integrityCheck ? '启用' : '禁用',
                  options: const ['启用', '禁用'],
                  onChanged: (value) {
                    ref.read(instanceConfigProvider.notifier)
                        .setIntegrityCheck(value == '启用');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 游戏设置
          _buildSectionTitle('游戏设置'),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              children: [
                // 内存分配滑块
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.memory,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '内存分配',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '为此版本分配的内存大小 (MB)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${config.memoryMB ?? settings.memoryMB} MB',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Theme.of(context).colorScheme.primary,
                          inactiveTrackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          thumbColor: Theme.of(context).colorScheme.primary,
                          overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        ),
                        child: Slider(
                          value: (config.memoryMB ?? settings.memoryMB).toDouble(),
                          min: 512,
                          max: 8192,
                          divisions: 15,
                          onChanged: (value) {
                            ref.read(instanceConfigProvider.notifier)
                                .setMemoryMB(value.toInt());
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '512 MB',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '8192 MB',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // JVM 参数
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.terminal,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'JVM 参数',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '自定义 Java 虚拟机启动参数',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: InputDecoration(
                          hintText: '例如: -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        controller: TextEditingController(
                          text: config.jvmArguments?.join(' ') ?? settings.jvmArguments.join(' '),
                        ),
                        onSubmitted: (value) {
                          final args = value.split(' ').where((s) => s.isNotEmpty).toList();
                          ref.read(instanceConfigProvider.notifier).setJvmArguments(args);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Java 设置
          _buildSectionTitle('Java 设置'),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              children: [
                _buildTextFieldTile(
                  icon: Icons.code,
                  title: 'Java 路径',
                  subtitle: (config.javaPath ?? settings.javaPath).isNotEmpty
                      ? (config.javaPath ?? settings.javaPath)
                      : '使用全局设置 (自动检测)',
                  hintText: '留空使用全局设置',
                  onSubmitted: (value) {
                    ref.read(instanceConfigProvider.notifier).setJavaPath(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 窗口设置
          _buildSectionTitle('窗口设置'),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.fullscreen,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  title: const Text('全屏启动'),
                  subtitle: const Text('游戏以全屏模式启动'),
                  value: config.fullscreen ?? settings.fullscreen,
                  onChanged: (value) {
                    ref.read(instanceConfigProvider.notifier).setFullscreen(value);
                  },
                ),
                if (!(config.fullscreen ?? settings.fullscreen)) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.aspect_ratio,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '窗口大小',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '游戏窗口的宽度和高度',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: '宽',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                            keyboardType: TextInputType.number,
                            controller: TextEditingController(
                              text: (config.windowWidth ?? settings.windowWidth).toString(),
                            ),
                            onSubmitted: (value) {
                              final width = int.tryParse(value);
                              if (width != null) {
                                ref.read(instanceConfigProvider.notifier).setWindowSize(
                                  width: width,
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('×'),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: '高',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                            keyboardType: TextInputType.number,
                            controller: TextEditingController(
                              text: (config.windowHeight ?? settings.windowHeight).toString(),
                            ),
                            onSubmitted: (value) {
                              final height = int.tryParse(value);
                              if (height != null) {
                                ref.read(instanceConfigProvider.notifier).setWindowSize(
                                  height: height,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  Widget _buildTextFieldTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String hintText,
    required ValueChanged<String> onSubmitted,
  }) {
    return ExpansionTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
      title: Text(title),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onSubmitted: onSubmitted,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '快速操作',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  icon: Icons.folder_open,
                  label: '打开目录',
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  icon: Icons.archive,
                  label: '导出实例',
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  icon: Icons.delete_outline,
                  label: '删除实例',
                  color: Colors.red,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color?.withOpacity(0.1) ?? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
