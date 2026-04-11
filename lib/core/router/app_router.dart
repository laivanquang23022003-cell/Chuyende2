import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:appmanga/features/auth/presentation/pages/splash_page.dart';
import 'package:appmanga/features/auth/presentation/pages/login_page.dart';
import 'package:appmanga/features/auth/presentation/pages/register_page.dart';
import 'package:appmanga/features/home/presentation/pages/home_page.dart';
import 'package:appmanga/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:appmanga/core/di/injection.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final localAuth = sl<AuthLocalDataSource>();
      final isLoggedIn = await localAuth.getAccessToken() != null;
      
      final bool isAuthRoute = state.matchedLocation == '/login' || 
                               state.matchedLocation == '/register' ||
                               state.matchedLocation == '/splash';

      if (!isLoggedIn) {
        if (!isAuthRoute) return '/splash';
      } else {
        if (isAuthRoute) return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
