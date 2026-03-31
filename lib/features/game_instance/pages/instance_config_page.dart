import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/glass_card.dart';
import '../providers/dartcraft_provider.dart';
import '../providers/instance_config_provider.dart';

class VersionIconData {
  final IconData? icon;
  final String? assetPath;
  final List<Color> gradientColors;
  final Color shadowColor;

  const VersionIconData({
    this.icon,
    this.assetPath,
    required this.gradientColors,
    required this.shadowColor,
  });
}

VersionIconData getVersionIconData(String version) {
  final v = version.toLowerCase();
  
  if (v.contains('neoforge')) {
    return const VersionIconData(
      assetPath: 'assets/icons/neoforge.png',
      gradientColors: [Color(0xFF7C4DFF), Color(0xFF651FFF)],
      shadowColor: Color(0xFF7C4DFF),
    );
  } else if (v.contains('forge')) {
    return const VersionIconData(
      assetPath: 'assets/icons/forge.png',
      gradientColors: [Color(0xFF607D8B), Color(0xFF37474F)],
      shadowColor: Color(0xFF607D8B),
    );
  } else if (v.contains('fabric')) {
    return const VersionIconData(
      assetPath: 'assets/icons/fabric.png',
      gradientColors: [Color(0xFFDB7093), Color(0xFFC2185B)],
      shadowColor: Color(0xFFDB7093),
    );
  } else if (v.contains('quilt')) {
    return const VersionIconData(
      assetPath: 'assets/icons/quilt.png',
      gradientColors: [Color(0xFF26C6DA), Color(0xFF0097A7)],
      shadowColor: Color(0xFF26C6DA),
    );
  } else if (v.contains('optifine') || v.contains('optifabric')) {
    return const VersionIconData(
      assetPath: 'assets/icons/optifine.png',
      gradientColors: [Color(0xFFFFB74D), Color(0xFFF57C00)],
      shadowColor: Color(0xFFFFB74D),
    );
  } else if (v.contains('snapshot') || v.contains('pre') || v.contains('rc')) {
    return const VersionIconData(
      assetPath: 'assets/icons/snapshot.png',
      gradientColors: [Color(0xFF7E57C2), Color(0xFF512DA8)],
      shadowColor: Color(0xFF7E57C2),
    );
  } else {
    return const VersionIconData(
      assetPath: 'assets/icons/vanilla.png',
      gradientColors: [Color(0xFF81C784), Color(0xFF388E3C)],
      shadowColor: Color(0xFF81C784),
    );
  }
}

String getVersionTypeLabel(String version) {
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

class InstanceConfigPage extends ConsumerStatefulWidget {
  final String version;
  final bool isEmbedded;

  const InstanceConfigPage({
    super.key,
    required this.version,
    this.isEmbedded = false,
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
      child: Stack(
        children: [
          // 背景装饰
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 返回按钮和标题
                _buildHeader(),
                const SizedBox(height: 24),
                // 版本信息卡片
                _buildVersionInfoCard(),
                const SizedBox(height: 32),
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
                      const SizedBox(width: 32),
                      // 右侧快速操作
                      SizedBox(
                        width: 200,
                        child: _buildQuickActions(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        if (!widget.isEmbedded)
          IconButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.arrow_back),
            tooltip: '返回',
          ),
        if (!widget.isEmbedded)
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
    final iconData = getVersionIconData(widget.version);

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Hero(
            tag: 'icon_${widget.version}',
            child: Image.asset(
              iconData.assetPath!,
              width: 90,
              height: 90,
              errorBuilder: (_, __, ___) => Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: iconData.gradientColors,
                  ),
                ),
                child: const Icon(Icons.grass, size: 44, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.version,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildStatusChip(),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoTag(
                      getVersionTypeLabel(widget.version),
                      iconData.shadowColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '实例路径: .minecraft/versions/${widget.version}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildPrimaryLaunchButton(),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          const Text(
            '就绪',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildPrimaryLaunchButton() {
    return FilledButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.play_arrow_rounded, size: 24),
      label: const Text('启动游戏', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
      ),
    );
  }

  Widget _buildConfigList(GameSettings settings, InstanceConfig config) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 版本设置
          _buildSectionHeader(Icons.auto_awesome_rounded, '版本设置'),
          const SizedBox(height: 16),
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
          _buildSectionHeader(Icons.gamepad_rounded, '游戏设置'),
          const SizedBox(height: 16),
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
          _buildSectionHeader(Icons.terminal_rounded, 'Java 设置'),
          const SizedBox(height: 16),
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
          _buildSectionHeader(Icons.aspect_ratio_rounded, '运行窗口'),
          const SizedBox(height: 16),
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

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '快捷操作',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.folder_open_rounded,
                label: '浏览文件',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                icon: Icons.archive_outlined,
                label: '备份实例',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                icon: Icons.share_rounded,
                label: '分享代码',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              Divider(height: 1, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
              const SizedBox(height: 24),
              _buildActionButton(
                icon: Icons.delete_outline_rounded,
                label: '移除实例',
                color: Colors.red,
                onTap: () {},
              ),
            ],
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
    String? hintText,
    required ValueChanged<String> onSubmitted,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: SizedBox(
        width: 200,
        child: TextField(
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onSubmitted: onSubmitted,
        ),
      ),
    );
  }
}
