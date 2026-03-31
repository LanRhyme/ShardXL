// Dependency Injection Container
// lib/di/injection_container.dart

import 'package:get_it/get_it.dart';

import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/network/minecraft_api_datasource.dart';
import '../../data/datasources/network/auth_api_datasource.dart';
import '../../data/repositories/game_version_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/launch_config_repository.dart';
import '../../data/repositories/mod_repository.dart';
import '../../domain/repositories/iversion_repository.dart';
import '../../domain/repositories/iauth_repository.dart';
import '../../domain/usecases/get_versions_usecase.dart';
import '../../domain/usecases/launch_game_usecase.dart';
import '../../domain/usecases/authenticate_usecase.dart';
import '../../domain/usecases/download_version_usecase.dart';
import '../../services/launch_service.dart';
import '../../services/download_service.dart';
import '../../services/auth_service.dart';
import '../../services/mod_service.dart';
import '../../services/java_service.dart';
import '../../presentation/bloc/version/version_bloc.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/launch/launch_bloc.dart';
import '../../presentation/bloc/download/download_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ========================
  // BLoCs
  // ========================
  sl.registerFactory(() => VersionBloc(getVersions: sl()));
  sl.registerFactory(() => AuthBloc(authenticate: sl(), authService: sl()));
  sl.registerFactory(() => LaunchBloc(launchGame: sl(), authRepository: sl()));
  sl.registerFactory(() => DownloadBloc(downloadVersion: sl()));

  // ========================
  // Use Cases
  // ========================
  sl.registerLazySingleton(() => GetVersionsUseCase(sl()));
  sl.registerLazySingleton(() => LaunchGameUseCase(sl()));
  sl.registerLazySingleton(() => AuthenticateUseCase(sl()));
  sl.registerLazySingleton(() => DownloadVersionUseCase(sl()));

  // ========================
  // Services
  // ========================
  sl.registerLazySingleton(() => LaunchService(sl(), sl()));
  sl.registerLazySingleton(() => DownloadService());
  sl.registerLazySingleton(() => AuthService());
  sl.registerLazySingleton(() => ModService());
  sl.registerLazySingleton(() => JavaService());

  // ========================
  // Repositories
  // ========================
  sl.registerLazySingleton<IVersionRepository>(
    () => GameVersionRepository(
      localDataSource: sl(),
      networkDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepository(
      authApiDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton(() => LaunchConfigRepository(localDataSource: sl()));
  sl.registerLazySingleton(() => ModRepository(localDataSource: sl()));

  // ========================
  // Data Sources
  // ========================
  sl.registerLazySingleton<LocalDataSource>(() => LocalDataSourceImpl());
  sl.registerLazySingleton<MinecraftApiDataSource>(
    () => MinecraftApiDataSourceImpl(),
  );
  sl.registerLazySingleton<AuthApiDataSource>(
    () => AuthApiDataSourceImpl(),
  );
}
