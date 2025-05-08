import 'package:go_router/go_router.dart';
import '../screens/login/sign-up/sign-up_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/go_design_screen.dart';
import 'child_routes.dart';
import 'parent_routes.dart';
import 'auth_gate.dart';
import 'package:flutter/material.dart';


final GoRouter IVRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthGate(),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
      const NoTransitionPage(child: LoginScreen()),
      routes: [
        GoRoute(
          path: 'sign-up',
          builder: (context, state) => const SignUpScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/design',
      builder: (context, state) => const GoDesignScreen(),
    ),
    childRoutes,
    parentRoutes,
  ],
);
