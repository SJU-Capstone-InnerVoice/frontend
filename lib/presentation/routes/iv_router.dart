import 'package:go_router/go_router.dart';
import '../screens/login/login_screen.dart';
import '../screens/mode/mode_screen.dart';

import 'child_routes.dart';
import 'parent_routes.dart';

final GoRouter IVRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/mode',
      builder: (context, state) => const ModeScreen(),
    ),
    childRoutes,
    parentRoutes,
  ],
);