import 'package:go_router/go_router.dart';
import '../screens/login/sign-up/sign-up_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/mode/mode_screen.dart';
import '../screens/go_design_screen.dart';
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
          path: 'sign-up',
          builder: (context, state) => const SignUpScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/mode',
      builder: (context, state) => const ModeScreen(),
    ),
    GoRoute(
      path: '/design',
      builder: (context, state) => const GoDesignScreen(),
    ),
    childRoutes,
    parentRoutes,
  ],
);
