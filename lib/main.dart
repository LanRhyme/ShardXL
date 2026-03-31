// ShardXL - Minecraft Java Edition Launcher
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/version/version_bloc.dart';
import 'presentation/bloc/launch/launch_bloc.dart';
import 'presentation/bloc/download/download_bloc.dart';
import 'presentation/pages/home/home_page.dart';
import 'di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const ShardXLApp());
}

class ShardXLApp extends StatelessWidget {
  const ShardXLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<VersionBloc>()),
        BlocProvider(create: (_) => di.sl<LaunchBloc>()),
        BlocProvider(create: (_) => di.sl<DownloadBloc>()),
      ],
      child: MaterialApp(
        title: 'ShardXL',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomePage(),
      ),
    );
  }
}
