import 'package:equatable/equatable.dart';
import 'package:appmanga/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  final bool isFollowLoading;
  final bool isUpdateLoading;

  const ProfileLoaded({
    required this.profile,
    this.isFollowLoading = false,
    this.isUpdateLoading = false,
  });

  ProfileLoaded copyWith({
    ProfileEntity? profile,
    bool? isFollowLoading,
    bool? isUpdateLoading,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      isFollowLoading: isFollowLoading ?? this.isFollowLoading,
      isUpdateLoading: isUpdateLoading ?? this.isUpdateLoading,
    );
  }

  @override
  List<Object?> get props => [profile, isFollowLoading, isUpdateLoading];
}

class ProfileUpdateSuccess extends ProfileState {
  final ProfileEntity profile;
  const ProfileUpdateSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
