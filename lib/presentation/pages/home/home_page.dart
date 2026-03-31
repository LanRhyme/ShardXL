// ShardXL Home Page
// lib/presentation/pages/home/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/version/version_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/launch/launch_bloc.dart';
import '../../widgets/version_card/version_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load versions on startup
    context.read<VersionBloc>().add(const LoadVersionsEvent());
    context.read<AuthBloc>().add(const CheckAuthStatusEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Icon(
                    Icons.games,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ShardXL',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.version_outlined),
                selectedIcon: Icon(Icons.version),
                label: Text('Versions'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.extension_outlined),
                selectedIcon: Icon(Icons.extension),
                label: Text('Mods'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildVersionsContent();
      case 2:
        return _buildModsContent();
      case 3:
        return _buildSettingsContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to ShardXL',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Your Minecraft Java Edition Launcher',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),
          // Quick Launch Card
          BlocBuilder<VersionBloc, VersionState>(
            builder: (context, state) {
              return BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  final hasVersion =
                      state is VersionsLoaded && state.selectedVersion != null;
                  final isAuthed = authState is Authenticated;

                  return Card(
                    child: InkWell(
                      onTap: hasVersion && isAuthed
                          ? () => _launchGame()
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Icon(
                              Icons.play_circle_fill,
                              size: 64,
                              color: hasVersion && isAuthed
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Play',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  if (!hasVersion || !isAuthed)
                                    Text(
                                      !isAuthed
                                          ? 'Please login first'
                                          : 'Select a version to play',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                          ),
                                    )
                                  else
                                    Text(
                                      state.selectedVersion?.id ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVersionsContent() {
    return const Center(child: Text('Versions — coming soon'));
  }

  Widget _buildModsContent() {
    return const Center(child: Text('Mods — coming soon'));
  }

  Widget _buildSettingsContent() {
    return const Center(child: Text('Settings — coming soon'));
  }

  void _launchGame() {
    context.read<LaunchBloc>().add(const LaunchGameEvent());
  }
}
