import 'package:equatable/equatable.dart';
import '../../domain/entities/explore_data.dart';

abstract class ExploreState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExploreInitial extends ExploreState {}

class ExploreLoading extends ExploreState {}

class ExploreLoaded extends ExploreState {
  final ExploreData data;

  ExploreLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

class ExploreError extends ExploreState {
  final String message;
  ExploreError(this.message);

  @override
  List<Object?> get props => [message];
}
