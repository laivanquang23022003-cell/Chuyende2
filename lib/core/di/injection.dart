import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_data_usecase.dart';
import '../../features/home/domain/usecases/filter_by_genre_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

// Explore feature
import '../../features/explore/data/datasources/explore_remote_data_source.dart';
import '../../features/explore/data/repositories/explore_repository_impl.dart';
import '../../features/explore/domain/repositories/explore_repository.dart';
import '../../features/explore/domain/usecases/get_explore_data_usecase.dart';
import '../../features/explore/presentation/bloc/explore_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => ApiClient());

  // Data sources
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceMock(),
  );
  sl.registerLazySingleton<ExploreRemoteDataSource>(
    () => ExploreRemoteDataSourceMock(),
  );

  // Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ExploreRepository>(
    () => ExploreRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetHomeDataUseCase(sl()));
  sl.registerLazySingleton(() => FilterByGenreUseCase(sl()));
  sl.registerLazySingleton(() => GetExploreDataUseCase(sl()));

  // Bloc
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
