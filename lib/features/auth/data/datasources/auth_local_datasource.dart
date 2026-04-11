import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens({required String accessToken, required String refreshToken});
  Future<void> saveUser(UserModel user);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<UserModel?> getUser();
  Future<void> clearAuthData();
  Future<bool> hasOnboardingDone();
  Future<void> setOnboardingDone();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'user_info';
  static const _onboardingKey = 'onboarding_done';

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await secureStorage.write(key: _accessTokenKey, value: accessToken);
    await secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await sharedPreferences.setString(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<String?> getAccessToken() => secureStorage.read(key: _accessTokenKey);

  @override
  Future<String?> getRefreshToken() => secureStorage.read(key: _refreshTokenKey);

  @override
  Future<UserModel?> getUser() async {
    final userStr = sharedPreferences.getString(_userKey);
    if (userStr == null) return null;
    return UserModel.fromJson(jsonDecode(userStr));
  }

  @override
  Future<void> clearAuthData() async {
    await secureStorage.delete(key: _accessTokenKey);
    await secureStorage.delete(key: _refreshTokenKey);
    await sharedPreferences.remove(_userKey);
  }

  @override
  Future<bool> hasOnboardingDone() async {
    return sharedPreferences.getBool(_onboardingKey) ?? false;
  }

  @override
  Future<void> setOnboardingDone() async {
    await sharedPreferences.setBool(_onboardingKey, true);
  }
}
