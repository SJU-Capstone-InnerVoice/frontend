import 'package:go_router/go_router.dart';
import '../screens/login/signup/signup_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/mode/mode_screen.dart';

import 'child_routes.dart';
import 'parent_routes.dart';

final GoRouter IVRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/login',
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
      routes: [
        GoRoute(
            path: 'signup',
          builder: (context, state) => const SignupScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/mode',
      builder: (context, state) => const ModeScreen(),
    ),
    childRoutes,
    parentRoutes,
  ],
);