// ShardXL 动态背景组件
// lib/core/widgets/shard_background.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

import '../../../features/settings/providers/theme_provider.dart';

/// 动态背景组件
/// 根据主题配置显示不同类型的背景
class ShardBackground extends ConsumerStatefulWidget {
  final Widget child;

  const ShardBackground({super.key, required this.child});

  @override
  ConsumerState<ShardBackground> createState() => _ShardBackgroundState();
}

class _ShardBackgroundState extends ConsumerState<ShardBackground> {
  String _previousBackgroundType = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final backgroundType = ref.read(shardThemeProvider).theme.backgroundType;
    _previousBackgroundType = backgroundType;
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(shardThemeProvider);
    final shardTheme = themeState.theme;
    final colorScheme = Theme.of(context).colorScheme;

    final currentBackgroundType = shardTheme.backgroundType;

    if (_previousBackgroundType == 'mica' && currentBackgroundType != 'mica') {
      _resetWindowEffect();
    } else if (_previousBackgroundType != 'mica' && currentBackgroundType == 'mica') {
      _MicaBackground.applyTransparentEffect(colorScheme);
    }
    _previousBackgroundType = currentBackgroundType;

    return RepaintBoundary(
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _buildBackground(
                colorScheme: colorScheme,
                primaryColor: shardTheme.primaryColor,
                backgroundType: currentBackgroundType,
                backgroundImagePath: shardTheme.backgroundImagePath,
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }

  Future<void> _resetWindowEffect() async {
    if (!Platform.isWindows) return;
    try {
      await Window.setEffect(
        effect: WindowEffect.disabled,
        color: Colors.transparent,
      );
    } catch (e) {
      debugPrint('Failed to reset window effect: $e');
    }
  }

  /// 根据背景类型构建不同的背景
  Widget _buildBackground({
    required ColorScheme colorScheme,
    required Color primaryColor,
    required String backgroundType,
    String? backgroundImagePath,
  }) {
    switch (backgroundType) {
      case 'solid':
        return Container(color: colorScheme.surfaceContainerLowest);

      case 'gradient':
        return _GradientBackground(colorScheme: colorScheme, primaryColor: primaryColor);

      case 'image':
        return _ImageBackground(
          colorScheme: colorScheme,
          imagePath: backgroundImagePath,
        );

      case 'dynamic':
        return _DynamicBackground(primaryColor: primaryColor, colorScheme: colorScheme);

      case 'mica':
        return _MicaBackground(colorScheme: colorScheme, primaryColor: primaryColor);

      default:
        return Container(color: colorScheme.surfaceContainerLowest);
    }
  }
}

/// 静态渐变背景
class _GradientBackground extends StatefulWidget {
  final ColorScheme colorScheme;
  final Color primaryColor;

  const _GradientBackground({
    required this.colorScheme,
    required this.primaryColor,
  });

  @override
  State<_GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<_GradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(widget.primaryColor);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: widget.colorScheme.surfaceContainerLowest,
          ),
          child: RepaintBoundary(
            child: Stack(
              children: [
                // 主渐变背景
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        widget.colorScheme.surfaceContainerLowest,
                        Color.lerp(
                          widget.colorScheme.surfaceContainerLowest,
                          widget.colorScheme.surfaceContainer,
                          0.5 + (_controller.value * 0.1),
                        )!,
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),

                // 顶部渐变光晕 - 缓慢浮动
                Positioned(
                  top: -200 + (_controller.value * 40 - 20),
                  right: -100 + (_controller.value * 30 - 15),
                  child: Container(
                    width: 500,
                    height: 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          HSLColor.fromAHSL(
                            0.15 + (_controller.value * 0.03),
                            hsl.hue,
                            hsl.saturation * 0.5,
                            0.5,
                          ).toColor(),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // 底部渐变光晕 - 缓慢浮动
                Positioned(
                  bottom: -150 + (_controller.value * 30 - 15),
                  left: -100 + (_controller.value * 25 - 12.5),
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          HSLColor.fromAHSL(
                            0.08 + (_controller.value * 0.02),
                            (hsl.hue + 30) % 360,
                            hsl.saturation * 0.3,
                            0.4,
                          ).toColor(),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // 中部辅助光晕
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.4 + (_controller.value * 20 - 10),
                  left: -50 + (_controller.value * 30 - 15),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          HSLColor.fromAHSL(
                            0.05 + (_controller.value * 0.02),
                            (hsl.hue + 60) % 360,
                            hsl.saturation * 0.4,
                            0.45,
                          ).toColor(),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 图片背景
class _ImageBackground extends StatelessWidget {
  final ColorScheme colorScheme;
  final String? imagePath;

  const _ImageBackground({
    required this.colorScheme,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.surfaceContainerLowest,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imagePath != null && imagePath!.isNotEmpty)
            _buildImage()
          else
            _buildPlaceholder(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.surfaceContainerLowest.withValues(alpha: 0.3),
                  colorScheme.surfaceContainerLowest.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final file = File(imagePath!);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return Image.asset(
      imagePath!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: colorScheme.surfaceContainer,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '请选择背景图片',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 动态渐变背景
class _DynamicBackground extends StatefulWidget {
  final Color primaryColor;
  final ColorScheme colorScheme;

  const _DynamicBackground({
    required this.primaryColor,
    required this.colorScheme,
  });

  @override
  State<_DynamicBackground> createState() => _DynamicBackgroundState();
}

class _DynamicBackgroundState extends State<_DynamicBackground>
    with TickerProviderStateMixin {
  late AnimationController _primaryController;
  late AnimationController _secondaryController;
  late AnimationController _subtleController;

  @override
  void initState() {
    super.initState();
    
    _primaryController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    _secondaryController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);

    _subtleController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    _subtleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(widget.primaryColor);
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _primaryController,
        _secondaryController,
        _subtleController,
      ]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: widget.colorScheme.surfaceContainerLowest,
          ),
          child: RepaintBoundary(
            child: Stack(
              children: [
                // 微妙的整体渐变动画
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(
                        -1 + (_subtleController.value * 0.4),
                        -1 + (_subtleController.value * 0.4),
                      ),
                      end: Alignment(
                        1 - (_subtleController.value * 0.4),
                        1 - (_subtleController.value * 0.4),
                      ),
                      colors: [
                        widget.colorScheme.surfaceContainerLowest,
                        Color.lerp(
                          widget.colorScheme.surfaceContainerLowest,
                          widget.colorScheme.surfaceContainer,
                          0.3 + (_subtleController.value * 0.2),
                        )!,
                      ],
                    ),
                  ),
                ),

                // 主光晕 1（右上角）- 缓慢移动
                Positioned(
                  top: -200 + (_primaryController.value * 100),
                  right: -100 + (_primaryController.value * 80),
                  child: Container(
                    width: 500,
                    height: 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          HSLColor.fromAHSL(
                            0.15 + (_primaryController.value * 0.08),
                            hsl.hue,
                            hsl.saturation * 0.5,
                            0.45,
                          ).toColor(),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // 主光晕 2（左下角）- 缓慢移动
                Positioned(
                  bottom: -150 - (_primaryController.value * 80),
                  left: -150 + (_primaryController.value * 60),
                  child: Container(
                    width: 450,
                    height: 450,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          HSLColor.fromAHSL(
                            0.10 + (_primaryController.value * 0.05),
                            (hsl.hue + 45) % 360,
                            hsl.saturation * 0.4,
                            0.42,
                          ).toColor(),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // 辅助光晕 1（中右）- 快速移动
                Positioned(
                  top: screenSize.height * 0.3 + (_secondaryController.value * 80 - 40),
                  right: -80 + (_secondaryController.value * 50 - 25),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          HSLColor.fromAHSL(
                            0.08 + (_secondaryController.value * 0.04),
                            (hsl.hue + 90) % 360,
                            hsl.saturation * 0.6,
                            0.5,
                          ).toColor(),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // 辅助光晕 2（中左）- 快速移动
                Positioned(
                  top: screenSize.height * 0.5 - (_secondaryController.value * 60 + 30),
                  left: -60 + (_secondaryController.value * 40 - 20),
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          HSLColor.fromAHSL(
                            0.06 + (_secondaryController.value * 0.03),
                            (hsl.hue + 180) % 360,
                            hsl.saturation * 0.35,
                            0.48,
                          ).toColor(),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // 细小光点效果
                RepaintBoundary(
                  child: Stack(
                    children: _buildFloatingParticles(hsl),
                  ),
                ),

                // 底部微弱渐变
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: screenSize.height * 0.3,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          widget.colorScheme.surfaceContainer.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建浮动粒子效果
  List<Widget> _buildFloatingParticles(HSLColor hsl) {
    final particles = <Widget>[];
    final screenSize = MediaQuery.of(context).size;

    for (int i = 0; i < 6; i++) {
      final baseX = (screenSize.width * (0.1 + i * 0.15));
      final baseY = (screenSize.height * (0.2 + (i % 3) * 0.25));
      final size = 8.0 + (i % 3) * 4.0;
      final animationValue = (_primaryController.value + i * 0.15) % 1.0;

      particles.add(
        Positioned(
          top: baseY + (animationValue * 30 - 15),
          left: baseX + (_secondaryController.value * 20 - 10),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: HSLColor.fromAHSL(
                0.03 + (animationValue * 0.02),
                (hsl.hue + i * 60) % 360,
                hsl.saturation * 0.5,
                0.6,
              ).toColor(),
            ),
          ),
        ),
      );
    }

    return particles;
  }
}

/// Mica 背景效果（高斯模糊窗口）
class _MicaBackground extends StatefulWidget {
  final ColorScheme colorScheme;
  final Color primaryColor;

  const _MicaBackground({
    required this.colorScheme,
    required this.primaryColor,
  });

  static bool _isApplyingEffect = false;

  static Future<void> applyTransparentEffect(ColorScheme colorScheme) async {
    if (!Platform.isWindows) return;
    if (_isApplyingEffect) return;

    _isApplyingEffect = true;
    try {
      final isDark = colorScheme.brightness == Brightness.dark;
      await Window.setEffect(
        effect: WindowEffect.acrylic,
        color: isDark
            ? const Color(0x99000000)
            : const Color(0x99FFFFFF),
        dark: isDark,
      );
    } catch (e) {
      debugPrint('Failed to apply Acrylic effect: $e');
    } finally {
      _isApplyingEffect = false;
    }
  }

  @override
  State<_MicaBackground> createState() => _MicaBackgroundState();
}

class _MicaBackgroundState extends State<_MicaBackground> {
  @override
  void didUpdateWidget(_MicaBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.colorScheme.brightness != widget.colorScheme.brightness) {
      _MicaBackground.applyTransparentEffect(widget.colorScheme);
    }
  }

  @override
  void dispose() {
    _resetEffect();
    super.dispose();
  }

  Future<void> _resetEffect() async {
    if (!Platform.isWindows) return;

    try {
      await Window.setEffect(
        effect: WindowEffect.disabled,
        color: widget.colorScheme.surfaceContainerLowest,
        dark: widget.colorScheme.brightness == Brightness.dark,
      );
    } catch (e) {
      debugPrint('Failed to reset window effect: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.transparent);
  }
}