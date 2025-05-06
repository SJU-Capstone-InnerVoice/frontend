import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../../logic/providers/user/user_provider.dart';

class FriendListScreen extends StatelessWidget {
  const FriendListScreen({super.key});

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
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://picsum.photos/seed/${child.friendId}/100/100',
                    ),
                  ),
                  title: Text(child.friendName),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${child.friendName}을 눌렀습니다')),
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