// ShardXL Shadcn 风格颜色选择器
// lib/core/widgets/shadcn_color_picker.dart
//
// 可复用的颜色选择器组件，支持：
// - 预设颜色选择
// - 自定义颜色选择（HSL 色轮 + HEX 输入）
// - shadcn 风格设计

import 'package:flutter/material.dart';
import '../theme/shard_theme.dart';

class ShadcnColorPicker extends StatelessWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorChanged;
  final List<Color>? presetColors;
  final double size;

  const ShadcnColorPicker({
    super.key,
    required this.currentColor,
    required this.onColorChanged,
    this.presetColors,
    this.size = 32,
  });

  static const List<Color> defaultPresetColors = [
    Color(0xFF4A90D9),
    Color(0xFF7C6BD9),
    Color(0xFF5C4DB8),
    Color(0xFF4AADD9),
    Color(0xFF4ACCD9),
    Color(0xFF4AD99A),
    Color.fromARGB(255, 170, 207, 109),
    Color(0xFFD9C84A),
    Color(0xFFD99A4A),
    Color(0xFFD94A6A),
    Color(0xFFD94A8A),
    Color(0xFFB84AD9),
  ];

  void _showColorPickerPopup(
    BuildContext context,
    Offset position,
    Size anchorSize,
  ) {
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ColorPickerPopup(
        anchorPosition: position,
        anchorSize: anchorSize,
        currentColor: currentColor,
        onColorChanged: (color) {
          onColorChanged(color);
          overlayEntry?.remove();
        },
        onDismiss: () {
          overlayEntry?.remove();
        },
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        _showColorPickerPopup(
          context,
          position,
          box.size,
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 2,
          ),
          gradient: const SweepGradient(
            colors: [
              Color(0xFFFF0000),
              Color(0xFFFFFF00),
              Color(0xFF00FF00),
              Color(0xFF00FFFF),
              Color(0xFF0000FF),
              Color(0xFFFF00FF),
              Color(0xFFFF0000),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: size * 0.4,
            height: size * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorPickerPopup extends StatefulWidget {
  final Offset anchorPosition;
  final Size anchorSize;
  final Color currentColor;
  final ValueChanged<Color> onColorChanged;
  final VoidCallback onDismiss;

  const _ColorPickerPopup({
    required this.anchorPosition,
    required this.anchorSize,
    required this.currentColor,
    required this.onColorChanged,
    required this.onDismiss,
  });

  @override
  State<_ColorPickerPopup> createState() => _ColorPickerPopupState();
}

class _ColorPickerPopupState extends State<_ColorPickerPopup> {
  late double _hue;
  late double _saturation;
  late double _value;
  late TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.currentColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
    _hexController = TextEditingController(
      text: _colorToHex(widget.currentColor),
    );
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  Color get _currentColor {
    return HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor();
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  Color? _hexToColor(String hex) {
    try {
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  void _updateFromColor(Color color) {
    final hsv = HSVColor.fromColor(color);
    setState(() {
      _hue = hsv.hue;
      _saturation = hsv.saturation;
      _value = hsv.value;
      _hexController.text = _colorToHex(color);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeExtension = Theme.of(context).extension<ShardThemeExtension>();

    final screenSize = MediaQuery.of(context).size;
    const popupWidth = 220.0;
    const popupHeight = 280.0;

    double left = widget.anchorPosition.dx;
    double top = widget.anchorPosition.dy + widget.anchorSize.height + 8;

    if (left + popupWidth > screenSize.width - 16) {
      left = screenSize.width - popupWidth - 16;
    }
    if (left < 16) {
      left = 16;
    }

    if (top + popupHeight > screenSize.height - 16) {
      top = widget.anchorPosition.dy - popupHeight - 8;
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onDismiss,
          child: Container(color: Colors.transparent),
        ),
        Positioned(
          left: left,
          top: top,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(
              themeExtension?.cardBorderRadius ?? 12.0,
            ),
            color: colorScheme.surfaceContainerHigh,
            child: Container(
              width: popupWidth,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  themeExtension?.cardBorderRadius ?? 12.0,
                ),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(colorScheme),
                  const SizedBox(height: 12),
                  _buildSaturationLightnessPicker(colorScheme),
                  const SizedBox(height: 12),
                  _buildHueSlider(colorScheme),
                  const SizedBox(height: 12),
                  _buildHexInput(colorScheme, themeExtension),
                  const SizedBox(height: 12),
                  _buildApplyButton(colorScheme),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Row(
      children: [
        Text(
          '选择颜色',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: _currentColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaturationLightnessPicker(ColorScheme colorScheme) {
    final pureColor = HSVColor.fromAHSV(1.0, _hue, 1.0, 1.0).toColor();

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: (details) {
            _updateSaturationValue(details.localPosition, constraints.maxWidth);
          },
          onPanUpdate: (details) {
            _updateSaturationValue(details.localPosition, constraints.maxWidth);
          },
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: pureColor,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.white, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: (_saturation * constraints.maxWidth).clamp(0.0, constraints.maxWidth - 14),
                    top: ((1 - _value) * 120).clamp(0.0, 106),
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateSaturationValue(Offset localPosition, double width) {
    setState(() {
      _saturation = (localPosition.dx / width).clamp(0.0, 1.0);
      _value = (1 - localPosition.dy / 120).clamp(0.0, 1.0);
      _hexController.text = _colorToHex(_currentColor);
    });
  }

  Widget _buildHueSlider(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '色相',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onPanStart: (details) {
            _updateHue(details.localPosition.dx);
          },
          onPanUpdate: (details) {
            _updateHue(details.localPosition.dx);
          },
          child: Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF0000),
                  Color(0xFFFFFF00),
                  Color(0xFF00FF00),
                  Color(0xFF00FFFF),
                  Color(0xFF0000FF),
                  Color(0xFFFF00FF),
                  Color(0xFFFF0000),
                ],
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Positioned(
                      left: (_hue / 360 * constraints.maxWidth - 6).clamp(0.0, constraints.maxWidth - 12),
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _updateHue(double dx) {
    setState(() {
      _hue = (dx / 196 * 360).clamp(0.0, 360.0);
      _hexController.text = _colorToHex(_currentColor);
    });
  }

  Widget _buildHexInput(ColorScheme colorScheme, ShardThemeExtension? themeExtension) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(
          themeExtension?.buttonBorderRadius ?? 8.0,
        ),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _currentColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _hexController,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: '#FFFFFF',
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (value) {
                final color = _hexToColor(value);
                if (color != null) {
                  _updateFromColor(color);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () {
          widget.onColorChanged(_currentColor);
        },
        style: FilledButton.styleFrom(
          backgroundColor: _currentColor,
          foregroundColor: _getContrastColor(_currentColor),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: const Text('应用'),
      ),
    );
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
