import 'package:dio/dio.dart';
import '../models/auth_token_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokenModel> login(String email, String password);
  Future<AuthTokenModel> register({
    required String email,
    required String password,
    required String username,
    String? avatarUrl,
  });
  Future<AuthTokenModel> loginWithGoogle(String googleIdToken);
  Future<void> logout();
  Future<AuthTokenModel> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<AuthTokenModel> login(String email, String password) async {
    final response = await dio.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });
    return AuthTokenModel.fromJson(response.data['data']);
  }

  @override
  Future<AuthTokenModel> register({
    required String email,
    required String password,
    required String username,
    String? avatarUrl,
  }) async {
    final response = await dio.post('/api/auth/register', data: {
      'email': email,
      'password': password,
      'username': username,
      'avatar_url': avatarUrl,
    });
    return AuthTokenModel.fromJson(response.data['data']);
  }

  @override
  Future<AuthTokenModel> loginWithGoogle(String googleIdToken) async {
    final response = await dio.post('/api/auth/google', data: {
      'id_token': googleIdToken,
    });
    return AuthTokenModel.fromJson(response.data['data']);
  }

  @override
  Future<void> logout() async {
    await dio.post('/api/auth/logout');
  }

  @override
  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    final response = await dio.post('/api/auth/refresh', data: {
      'refresh_token': refreshToken,
    });
    return AuthTokenModel.fromJson(response.data['data']);
  }
}
