import 'package:go_router/go_router.dart';
import '../screens/child/child_screen.dart';

final childRoutes = GoRoute(
  path: '/child',
  builder: (context, state) => const ChildScreen(),
  routes: [
    GoRoute(
      path: 'call',
      builder: (context, state) => const ChildScreen(),
    ),
    GoRoute(
      path: 'setting',
      builder: (context, state) => const ChildScreen(),
    ),
  ],
);