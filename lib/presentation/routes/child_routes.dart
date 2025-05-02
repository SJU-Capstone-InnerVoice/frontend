import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../screens/child/child_screen.dart';
import '../screens/child/call/call_screen.child.dart';
import '../screens/child/call/start/call_start_screen.child.dart';
import '../screens/child/setting/setting_screen.child.dart';
import '../screens/child/setting/friends/check/friend_request_check_screen.dart';

final childRoutes = ShellRoute(
  builder: (context, state, child) => ChildScreen(child: child),
  routes: [
    GoRoute(
      path: '/child/call',
      builder: (context, state) => const CallScreen(),
      routes: [
        GoRoute(
          path: 'start',
          builder: (context, state) => const CallStartScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/child/settings',
      builder: (context, state) => const SettingScreen(),
      routes: [
        GoRoute(
          path: 'friends',
          builder: (context, state) => const SizedBox.shrink(), // dummy
          routes: [
            GoRoute(
              path: 'list',
              builder: (context, state) => const SizedBox.shrink(), // dummy
            ),
            GoRoute(
              path: 'check',
              builder: (context, state) => const FriendRequestCheckScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
