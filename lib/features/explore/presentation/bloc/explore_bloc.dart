import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_explore_data_usecase.dart';
import 'explore_event.dart';
import 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final GetExploreDataUseCase getExploreDataUseCase;

  ExploreBloc({required this.getExploreDataUseCase}) : super(ExploreInitial()) {
    on<ExploreLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(ExploreLoadRequested event, Emitter<ExploreState> emit) async {
    emit(ExploreLoading());
    final result = await getExploreDataUseCase();
    result.fold(
      (failure) => emit(ExploreError(failure.message)),
      (data) => emit(ExploreLoaded(data: data)),
    );
  }
}
