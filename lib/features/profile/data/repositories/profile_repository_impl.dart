import 'package:dartz/dartz.dart';
import 'package:appmanga/core/error/error_handler.dart';
import 'package:appmanga/core/error/failures.dart';
import 'package:appmanga/core/storage/local_storage.dart';
import 'package:appmanga/features/profile/domain/entities/profile_entity.dart';
import 'package:appmanga/features/profile/domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remote;
  final LocalStorage _localStorage;

  ProfileRepositoryImpl(this._remote, this._localStorage);

  @override
  Future<Either<Failure, ProfileEntity>> getUserProfile(String userId) async {
    try {
      final currentUserId = _localStorage.getUserId() ?? '';
      final result = await _remote.getUserProfile(userId, currentUserId);
      return Right(result);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile({String? username, String? avatarUrl}) async {
    try {
      final currentUserId = _localStorage.getUserId() ?? '';
      final result = await _remote.updateProfile(currentUserId, username: username, avatarUrl: avatarUrl);
      return Right(result);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> followUser(String userId) async {
    try {
      await _remote.followUser(userId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> unfollowUser(String userId) async {
    try {
      await _remote.unfollowUser(userId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
