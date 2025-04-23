import 'package:go_router/go_router.dart';
import '../screens/parent/parent_screen.dart';
import '../screens/parent/call/call_screen.dart';
import '../screens/parent/summary/summary_screen.dart';

final parentRoutes = ShellRoute(
  builder: (context, state, child) => ParentScreen(child: child),
  routes: [
    GoRoute(
      path: '/parent/call',
      builder: (context, state) => const CallScreen(),
    ),
    GoRoute(
      path: '/parent/summary',
      builder: (context, state) => const SummaryScreen(),
    ),
    GoRoute(
      path: '/parent/setting',
      builder: (context, state) => const CallScreen(),
    ),
  ],
);