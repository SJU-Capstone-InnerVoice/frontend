import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../screens/child/child_screen.dart';
import '../screens/child/call/call_screen.child.dart';
import '../screens/child/call/start/call_start_screen.child.dart';
import '../screens/child/call/waiting/call_waiting_screen.child.dart';
import '../screens/child/call/end/call_end_screen.child.dart';
import '../screens/child/setting/setting_screen.child.dart';
import '../screens/child/friends/check/friend_request_check_screen.dart';

final childRoutes = ShellRoute(
  builder: (context, state, child) => ChildScreen(child: child),
  routes: [
    GoRoute(
      path: '/child/call',
      pageBuilder: (context, state) =>
      const NoTransitionPage(child: CallScreen()),
      routes: [
        GoRoute(
          path: 'start',
          builder: (context, state) => const CallStartScreen(),
        ),
        GoRoute(
          path: 'waiting',
          builder: (context, state) => const CallWaitingScreen(),
        ),
        GoRoute(
          path: 'end',
          builder: (context, state) => const CallEndScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/child/settings',
      builder: (context, state) => const SettingScreen(),
    ),
    GoRoute(
      path: '/child/friends',
      builder: (context, state) => const SizedBox.shrink(), // dummy
      routes: [
        GoRoute(
          path: 'check',
          builder: (context, state) => const FriendRequestCheckScreen(),
        ),
      ],
    ),
  ],
);
