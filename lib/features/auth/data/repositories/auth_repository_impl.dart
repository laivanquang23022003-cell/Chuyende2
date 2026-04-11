import 'package:dartz/dartz.dart';
import 'package:appmanga/core/error/failures.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthToken>> login(String email, String password) async {
    try {
      final token = await remoteDataSource.login(email, password);
      await localDataSource.saveTokens(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
      );
      await localDataSource.saveUser(token.user as UserModel);
      return Right(token);
    } catch (e) {
      return Left(ServerFailure('Đăng nhập thất bại. Vui lòng kiểm tra lại email/mật khẩu.'));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> register({
    required String email,
    required String password,
    required String username,
    String? avatarUrl,
  }) async {
    try {
      final token = await remoteDataSource.register(
        email: email,
        password: password,
        username: username,
        avatarUrl: avatarUrl,
      );
      await localDataSource.saveTokens(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
      );
      await localDataSource.saveUser(token.user as UserModel);
      return Right(token);
    } catch (e) {
      return Left(ServerFailure('Đăng ký thất bại. Email hoặc tên đăng nhập có thể đã tồn tại.'));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> loginWithGoogle(String googleIdToken) async {
    try {
      final token = await remoteDataSource.loginWithGoogle(googleIdToken);
      await localDataSource.saveTokens(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
      );
      await localDataSource.saveUser(token.user as UserModel);
      return Right(token);
    } catch (e) {
      return Left(ServerFailure('Đăng nhập Google thất bại.'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearAuthData();
      return const Right(null);
    } catch (e) {
      // Vẫn xóa data local dù remote fail
      await localDataSource.clearAuthData();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken) async {
    try {
      final token = await remoteDataSource.refreshToken(refreshToken);
      await localDataSource.saveTokens(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
      );
      return Right(token);
    } catch (e) {
      return Left(ServerFailure('Phiên đăng nhập hết hạn.'));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await localDataSource.getAccessToken();
    return token != null;
  }
}
