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

    return Stack(
      children: [
        Positioned.fill(
          child: _buildBackground(
            colorScheme,
            shardTheme.primaryColor,
            currentBackgroundType,
            backgroundImagePath: shardTheme.backgroundImagePath,
          ),
        ),
        widget.child,
      ],
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
  Widget _buildBackground(ColorScheme colorScheme, Color primaryColor, String backgroundType, {String? backgroundImagePath}) {
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
class _GradientBackground extends StatelessWidget {
  final ColorScheme colorScheme;
  final Color primaryColor;

  const _GradientBackground({
    required this.colorScheme,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(primaryColor);
    
    return Container(
      decoration: BoxDecoration(
        // 主背景色
        color: colorScheme.surfaceContainerLowest,
      ),
      child: Stack(
        children: [
          // 顶部渐变光晕
          Positioned(
            top: -200,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    HSLColor.fromAHSL(0.15, hsl.hue, hsl.saturation * 0.5, 0.5).toColor(),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // 底部渐变光晕
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    HSLColor.fromAHSL(0.08, (hsl.hue + 30) % 360, hsl.saturation * 0.3, 0.4).toColor(),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // 主渐变
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.surfaceContainerLowest,
                  colorScheme.surfaceContainer,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ],
      ),
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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
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
          child: Stack(
            children: [
              // 动态光晕 1（右上）
              Positioned(
                top: -150 + (_controller.value * 50),
                right: -50 + (_controller.value * 30),
                child: Container(
                  width: 450,
                  height: 450,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        HSLColor.fromAHSL(
                          0.12 + (_controller.value * 0.05),
                          hsl.hue,
                          hsl.saturation * 0.6,
                          0.5,
                        ).toColor(),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // 动态光晕 2（左下）
              Positioned(
                bottom: -100 - (_controller.value * 40),
                left: -80 + (_controller.value * 20),
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        HSLColor.fromAHSL(
                          0.08 + (_controller.value * 0.03),
                          (hsl.hue + 40) % 360,
                          hsl.saturation * 0.4,
                          0.45,
                        ).toColor(),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // 微妙的噪点纹理效果（使用极细线性渐变模拟）
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
                        0.5,
                      )!,
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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