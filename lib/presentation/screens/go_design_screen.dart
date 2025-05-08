import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GoDesignScreen extends StatelessWidget {
  const GoDesignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      _Section(
        title: '🔐 인증 관련',
        items: [
          _DesignJumpItem(label: '로그인 화면', path: '/login'),
          _DesignJumpItem(label: '회원가입', path: '/login/sign-up'),
          _DesignJumpItem(label: '모드 선택', path: '/mode'),
        ],
      ),
      _Section(
        title: '👪 부모 기능',
        items: [
          _DesignJumpItem(label: '부모 통화 대기', path: '/parent/call/waiting'),
          _DesignJumpItem(label: '부모 통화 시작', path: '/parent/call/start'),
          _DesignJumpItem(label: '캐릭터 정보', path: '/parent/character/info'),
          _DesignJumpItem(label: '캐릭터 추가', path: '/parent/character/add'),
          _DesignJumpItem(label: '음성 합성', path: '/parent/character/voice/synthesis'),
          _DesignJumpItem(label: '요약 화면', path: '/parent/summary'),
          _DesignJumpItem(label: '설정 > 친구 목록', path: '/parent/settings/friend/list'),
          _DesignJumpItem(label: '설정 > 친구 요청', path: '/parent/settings/friend/request'),
        ],
      ),
      _Section(
        title: '🧒 자녀 기능',
        items: [
          _DesignJumpItem(label: '아이 통화 시작', path: '/child/call/start'),
          _DesignJumpItem(label: '아이 통화 종료', path: '/child/call/end'),
          _DesignJumpItem(label: '자녀 친구 요청 확인', path: '/child/settings/friends/check'),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 디자인 점프'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(thickness: 1.2),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: section.items
                    .map((item) => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade900,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => context.push(item.path),
                  child: Text(item.label),
                ))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _DesignJumpItem {
  final String label;
  final String path;

  _DesignJumpItem({required this.label, required this.path});
}

class _Section {
  final String title;
  final List<_DesignJumpItem> items;

  _Section({required this.title, required this.items});
}