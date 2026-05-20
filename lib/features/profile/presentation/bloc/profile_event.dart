import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  final String userId;
  const ProfileLoadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ProfileFollowToggled extends ProfileEvent {}

class ProfileUpdateRequested extends ProfileEvent {
  final String? username;
  final String? avatarUrl;

  const ProfileUpdateRequested({this.username, this.avatarUrl});

  @override
  List<Object?> get props => [username, avatarUrl];
}
