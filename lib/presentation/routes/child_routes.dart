import 'package:go_router/go_router.dart';
import '../screens/child/child_screen.dart';
import '../screens/child/call/call_screen.child.dart';
import '../screens/child/setting/setting_screen.child.dart';

final childRoutes = ShellRoute(
  builder: (context, state, child) => ChildScreen(child: child),
  routes: [
    GoRoute(
      path: '/child/call',
      builder: (context, state) => const CallScreen(),
    ),
    GoRoute(
      path: '/child/settings',
      builder: (context, state) => const SettingScreen(),
    ),
  ],
);