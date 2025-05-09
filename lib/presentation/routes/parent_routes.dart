import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../screens/parent/parent_screen.dart';
import '../screens/parent/call/call_screen.parent.dart';
import '../screens/parent/call/waiting/call_waiting_screen.parent.dart';
import '../screens/parent/call/start/call_start_screen.parent.dart';
import '../screens/parent/character/info/character_info_screen.dart';
import '../screens/parent/character/add/character_add_screen.dart';
import '../screens/parent/character/voice/synthesis/voice_synthesis_screen.dart';
import '../screens/parent/character/voice/result/voice_result.dart';
import '../screens/parent/summary/summary_screen.dart';
import '../screens/parent/setting/setting_screen.parent.dart';
import '../screens/parent/setting/friends/list/friend_list_screen.dart';
import '../screens/parent/setting/friends/request/friend_request_screen.dart';

final parentRoutes = ShellRoute(
  builder: (context, state, child) => ParentScreen(child: child),
  routes: [
    GoRoute(
      path: '/parent/call',
      pageBuilder: (context, state) =>
      const NoTransitionPage(child: CallScreen()),
      routes: [
        GoRoute(
          path: 'waiting',
          builder: (context, state) => const CallWaitingScreen(),
        ),
        GoRoute(
          path: 'start',
          builder: (context, state) => const CallStartScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/parent/character',
      builder: (context, state) => const SizedBox.shrink(), // dummy
      routes: [
        GoRoute(
          path: 'info',
          builder: (context, state) => const CharacterInfoScreen(),
        ),
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddCharacterScreen(),
        ),
        GoRoute(
          path: 'voice',
          builder: (context, state) => const SizedBox.shrink(), // dummy
          routes: [
            GoRoute(
              path: 'synthesis',
              builder: (context, state) => const VoiceSynthesisScreen(),
            ),
            GoRoute(
              path: 'result',
              builder: (context, state) => const VoiceResultScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/parent/summary',
      builder: (context, state) => const SummaryScreen(),
    ),
    GoRoute(
      path: '/parent/settings',
      builder: (context, state) => const SettingScreen(),
      routes: [
        GoRoute(
          path: 'friend',
          builder: (context, state) => const SizedBox.shrink(), // dummy
          routes: [
            GoRoute(
              path: 'list',
              builder: (context, state) => const FriendListScreen(),
            ),
            GoRoute(
              path: 'request',
              builder: (context, state) => const FriendRequestScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
