import 'package:go_router/go_router.dart';
import '../screens/parent/parent_screen.dart';
import '../screens/parent/call/call_screen.parent.dart';
import '../screens/parent/call/call-waiting/call-waiting_screen.dart';
import '../screens/parent/call/call-start/call-start_screen.parent.dart';
import '../screens/parent/summary/summary_screen.dart';
import '../screens/parent/setting/setting_screen.parent.dart';
import '../screens/parent/character-info/character-info_screen.dart';

final parentRoutes = ShellRoute(
  builder: (context, state, child) => ParentScreen(child: child),
  routes: [
    GoRoute(
      path: '/parent/call',
      builder: (context, state) => const CallScreen(),
      routes: [
        GoRoute(
          path: 'call-waiting',
          builder: (context, state) => const CallWaitingScreen(),
        ),
        GoRoute(
          path: 'call-start',
          builder: (context, state) => const CallStartScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/parent/character-info',
      builder: (context, state) => const CharacterInfoScreen(),
    ),
    GoRoute(
      path: '/parent/summary',
      builder: (context, state) => const SummaryScreen(),
    ),
    GoRoute(
      path: '/parent/settings',
      builder: (context, state) => const SettingScreen(),
    ),
  ],
);
