import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_data_usecase.dart';
import '../../features/home/domain/usecases/filter_by_genre_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => ApiClient());

  // Data sources - Using Mock for now to show UI
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceMock(),
  );

  // Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetHomeDataUseCase(sl()));
  sl.registerLazySingleton(() => FilterByGenreUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => HomeBloc(
      getHomeDataUseCase: sl(),
      filterByGenreUseCase: sl(),
    ),
  );
}
