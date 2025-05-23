import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inner_voice/data/datasources/local/auth_local_datasource.dart';
import 'package:inner_voice/logic/providers/communication/call_request_provider.dart';
import 'package:inner_voice/logic/providers/user/user_provider.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  void initState() {
    super.initState();

    // ✅ CallRequestProvider polling 중단
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CallRequestProvider>().stopPolling();
    });
  }

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
            title: const Text('부모 등록 확인'),
            onTap: () {
              context.push('/child/friends/check');
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