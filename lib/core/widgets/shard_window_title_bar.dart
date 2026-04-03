// ShardXL 自定义窗口标题栏
// lib/core/widgets/shard_window_title_bar.dart
//
// 提供无边框窗口的自定义标题栏，包含：
// - 应用图标和标题
// - 最小化、关闭按钮
// - 可拖拽移动窗口

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class ShardWindowTitleBar extends StatelessWidget {
  final String title;
  final double height;

  const ShardWindowTitleBar({
    super.key,
    this.title = 'ShardXL',
    this.height = 32,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          MoveWindow(
            child: Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAppIcon(context),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Row(
              children: [
                _MinimizeButton(colorScheme: colorScheme),
                _CloseButton(colorScheme: colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppIcon(BuildContext context) {
    return Image.asset(
      'assets/icons/logo.png',
      width: 16,
      height: 16,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.games,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        );
      },
    );
  }
}

class _MinimizeButton extends StatefulWidget {
  final ColorScheme colorScheme;

  const _MinimizeButton({required this.colorScheme});

  @override
  State<_MinimizeButton> createState() => _MinimizeButtonState();
}

class _MinimizeButtonState extends State<_MinimizeButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => appWindow.minimize(),
        child: Container(
          width: 46,
          height: 32,
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.colorScheme.onSurfaceVariant.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.remove,
            size: 16,
            color: widget.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatefulWidget {
  final ColorScheme colorScheme;

  const _CloseButton({required this.colorScheme});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => appWindow.close(),
        child: Container(
          width: 46,
          height: 32,
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.colorScheme.error.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.close,
            size: 16,
            color: _isHovered
                ? widget.colorScheme.error
                : widget.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
