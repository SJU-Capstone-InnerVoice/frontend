import 'package:go_router/go_router.dart';
import '../screens/parent/parent_screen.dart';

final parentRoutes = GoRoute(
  path: '/parent',
  builder: (context, state) => const ParentScreen(),
  routes: [
    GoRoute(
      path: 'call',
      builder: (context, state) => const ParentScreen(),

    ),
    GoRoute(
      path: 'summary',
      builder: (context, state) => const ParentScreen(),

    ),
    GoRoute(
      path: 'setting',
      builder: (context, state) => const ParentScreen(),

    ),
  ],
);