// ShardXL 关于页面
// lib/features/settings/pages/about_page.dart

import 'package:flutter/material.dart';
import '../../../core/widgets/glass_card.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(
                '关于',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            children: [
              Center(
                child: Column(
                  children: [
                    Icon(Icons.games, size: 64, color: colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      'ShardXL',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Minecraft Java Edition Launcher',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              GlassCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.tag),
                      title: const Text('版本'),
                      subtitle: const Text('0.1.0-alpha'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.code),
                      title: const Text('框架'),
                      subtitle: const Text('Flutter'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.gavel),
                      title: const Text('开源协议'),
                      subtitle: const Text('MIT License'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
