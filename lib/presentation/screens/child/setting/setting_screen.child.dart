import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inner_voice/data/datasources/local/auth_local_datasource.dart';
import 'package:inner_voice/logic/providers/user/user_provider.dart';
import 'package:provider/provider.dart';
class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
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
            title: const Text('친구 요청 확인'),
            onTap: () {
              context.go('/child/settings/friends/check');
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
            onTap: () async {
              userProvider.clear();
              await AuthLocalDataSource.clearUser();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}