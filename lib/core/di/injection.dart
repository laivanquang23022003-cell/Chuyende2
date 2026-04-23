import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:appmanga/core/network/dio_client.dart';
import 'package:appmanga/core/storage/token_manager.dart';
import 'package:appmanga/core/storage/local_storage.dart';

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

// Features - Manga (New)
import 'package:appmanga/features/manga/data/datasources/manga_remote_datasource.dart';
import 'package:appmanga/features/manga/data/repositories/manga_repository_impl.dart';
import 'package:appmanga/features/manga/domain/repositories/manga_repository.dart';
import 'package:appmanga/features/manga/domain/usecases/get_home_data_usecase.dart';
import 'package:appmanga/features/manga/domain/usecases/get_manga_list_usecase.dart';

// Feature Blocs
import 'package:appmanga/features/home/presentation/bloc/home_bloc.dart';
import 'package:appmanga/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:appmanga/features/search/presentation/bloc/search_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── Core & Storage ──────────────────────────
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPrefs);
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  
  sl.registerLazySingleton<LocalStorage>(() => LocalStorage(sl()));
  sl.registerLazySingleton<TokenManager>(() => TokenManager(sl()));
  sl.registerLazySingleton<DioClient>(() => DioClient(sl()));

  // ── Auth ─────────────────────────────
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LoginGoogleUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthUseCase(sl()));

  // ── Manga (Home, Explore, Search) ──────────────────
  sl.registerLazySingleton<MangaRemoteDataSource>(
    () => MangaRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<MangaRepository>(
    () => MangaRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetHomeDataUseCase(sl()));
  sl.registerLazySingleton(() => GetMangaListUseCase(sl()));

  // ── Blocs ─────────────────────────────
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
    ),
  );

  sl.registerFactory(
    () => ExploreBloc(
      getMangaListUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => SearchBloc(
      getMangaListUseCase: sl(),
    ),
  );
}
