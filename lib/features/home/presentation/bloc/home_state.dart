import 'package:equatable/equatable.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/entities/manga_card.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final HomeData data;
  final String selectedGenre;
  final List<MangaCard>? filteredManga;
  final bool isFiltering;

  HomeLoaded({
    required this.data,
    this.selectedGenre = 'Tất cả',
    this.filteredManga,
    this.isFiltering = false,
  });

  @override
  List<Object?> get props => [data, selectedGenre, filteredManga, isFiltering];

  HomeLoaded copyWith({
    HomeData? data,
    String? selectedGenre,
    List<MangaCard>? filteredManga,
    bool? isFiltering,
  }) {
    return HomeLoaded(
      data: data ?? this.data,
      selectedGenre: selectedGenre ?? this.selectedGenre,
      filteredManga: filteredManga ?? this.filteredManga,
      isFiltering: isFiltering ?? this.isFiltering,
    );
  }
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
