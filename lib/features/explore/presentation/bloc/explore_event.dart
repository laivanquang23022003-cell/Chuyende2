import 'package:equatable/equatable.dart';

abstract class ExploreEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExploreLoadRequested extends ExploreEvent {}
