import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import '../../domain/usecases/filter_by_genre_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeDataUseCase getHomeDataUseCase;
  final FilterByGenreUseCase filterByGenreUseCase;

  HomeBloc({
    required this.getHomeDataUseCase,
    required this.filterByGenreUseCase,
  }) : super(HomeInitial()) {
    on<HomeLoadRequested>(_onLoadRequested);
    on<HomeRefreshRequested>(_onRefreshRequested);
    on<HomeGenreFilterChanged>(_onGenreFilterChanged);
  }

  Future<void> _onLoadRequested(HomeLoadRequested event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    final result = await getHomeDataUseCase();
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (data) => emit(HomeLoaded(data: data)),
    );
  }

  Future<void> _onRefreshRequested(HomeRefreshRequested event, Emitter<HomeState> emit) async {
    final result = await getHomeDataUseCase();
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (data) => emit(HomeLoaded(data: data)),
    );
  }

  Future<void> _onGenreFilterChanged(HomeGenreFilterChanged event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      if (event.genre == 'Tất cả') {
        emit(currentState.copyWith(selectedGenre: 'Tất cả', filteredManga: null, isFiltering: false));
        return;
      }
      
      emit(currentState.copyWith(selectedGenre: event.genre, isFiltering: true));
      final result = await filterByGenreUseCase(event.genre);
      result.fold(
        (failure) => emit(currentState.copyWith(isFiltering: false)),
        (mangas) => emit(currentState.copyWith(filteredManga: mangas, isFiltering: false)),
      );
    }
  }
}
