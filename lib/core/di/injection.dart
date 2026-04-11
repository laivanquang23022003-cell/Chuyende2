import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:appmanga/core/network/api_client.dart';

// Features - Auth
import 'package:appmanga/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:appmanga/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:appmanga/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:appmanga/features/auth/domain/repositories/auth_repository.dart';
import 'package:appmanga/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:appmanga/features/auth/domain/usecases/login_google_usecase.dart';
import 'package:appmanga/features/auth/domain/usecases/login_usecase.dart';
import 'package:appmanga/features/auth/domain/usecases/logout_usecase.dart';
import 'package:appmanga/features/auth/domain/usecases/register_usecase.dart';
import 'package:appmanga/features/auth/presentation/bloc/auth_bloc.dart';

// Features - Home
import 'package:appmanga/features/home/data/datasources/home_remote_data_source.dart';
import 'package:appmanga/features/home/data/repositories/home_repository_impl.dart';
import 'package:appmanga/features/home/domain/repositories/home_repository.dart';
import 'package:appmanga/features/home/domain/usecases/filter_by_genre_usecase.dart';
import 'package:appmanga/features/home/domain/usecases/get_home_data_usecase.dart';
import 'package:appmanga/features/home/presentation/bloc/home_bloc.dart';

// Features - Explore
import 'package:appmanga/features/explore/data/datasources/explore_remote_data_source.dart';
import 'package:appmanga/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:appmanga/features/explore/domain/repositories/explore_repository.dart';
import 'package:appmanga/features/explore/domain/usecases/get_explore_data_usecase.dart';
import 'package:appmanga/features/explore/presentation/bloc/explore_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPrefs);
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // Data sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceMock(),
  );
  sl.registerLazySingleton<ExploreRemoteDataSource>(
    () => ExploreRemoteDataSourceMock(),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ExploreRepository>(
    () => ExploreRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LoginGoogleUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthUseCase(sl()));
  sl.registerLazySingleton(() => GetHomeDataUseCase(sl()));
  sl.registerLazySingleton(() => FilterByGenreUseCase(sl()));
  sl.registerLazySingleton(() => GetExploreDataUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      loginGoogleUseCase: sl(),
      logoutUseCase: sl(),
      checkAuthUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => HomeBloc(
      getHomeDataUseCase: sl(),
      filterByGenreUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ExploreBloc(
      getExploreDataUseCase: sl(),
    ),
  );
}
