import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';

final parentRoutes = GoRoute(
  path: '/parent',
  builder: (context, state) => const HomeScreen(),
  routes: [
    GoRoute(
      path: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: 'call',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: 'summary',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: 'setting',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);