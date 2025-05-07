import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inner_voice/logic/providers/network/dio_provider.dart';
import 'package:provider/provider.dart';
import '../../../../../../logic/providers/user/user_provider.dart';

class FriendListScreen extends StatefulWidget {
  const FriendListScreen({super.key});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  late final Dio _dio;
  @override
  void initState() {
    super.initState();
    _dio = context.read<DioProvider>().dio;
    context.read<UserProvider>().setChildList(_dio);
  }
  @override
  Widget build(BuildContext context) {
    final childList = context.watch<UserProvider>().user?.childList ?? [];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text('친구 목록'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('친구 요청하기'),
                onPressed: () {
                  context.push('/parent/settings/friend/request');
                },
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: childList.isEmpty
                ? const Center(child: Text('등록된 친구가 없습니다.'))
                : ListView.builder(
              itemCount: childList.length,
              itemBuilder: (context, index) {
                final child = childList[index];
                final userProvider = context.watch<UserProvider>();
                final activeChildId = userProvider.activeChildId;
                final isActive = child.friendId.toString() == activeChildId;
                return ListTile(
                  tileColor: isActive ? Colors.blue : null,
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://picsum.photos/seed/${child.friendId}/100/100',
                    ),
                  ),
                  title: Text(child.friendName),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.read<UserProvider>().setActivateChild(child.friendId.toString());

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${child.friendName}을(를) 활성화했습니다.')),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}