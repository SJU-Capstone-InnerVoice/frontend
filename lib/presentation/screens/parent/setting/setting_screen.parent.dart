import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('프로필 설정'),
            onTap: () {
              // TODO: 프로필 설정 이동
            },
          ),
          ListTile(
            title: const Text('자녀 관리'),
            onTap: () {
              context.go('/parent/settings/list');
            },
          ),
          ListTile(
            title: const Text('모드 선택하기'),
            onTap: () {
              context.go('/mode');
            },
          ),
          ListTile(
            title: const Text('보안 설정'),
            onTap: () {
              // TODO: 보안 설정 이동
            },
          ),
          ListTile(
            title: const Text('앱 정보'),
            onTap: () {
              // TODO: 앱 정보 이동
            },
          ),
          ListTile(
            title: const Text('로그아웃'),
            onTap: () {
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}