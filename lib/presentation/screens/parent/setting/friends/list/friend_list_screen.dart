import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FriendListScreen extends StatefulWidget {
  const FriendListScreen({super.key});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  final List<Map<String, String>> children = [
    {
      'name': '철수',
      'imageUrl': 'https://picsum.photos/seed/1/100/100',
    },
    {
      'name': '영희',
      'imageUrl': 'https://picsum.photos/seed/2/100/100',
    },
    {
      'name': '민수',
      'imageUrl': 'https://picsum.photos/seed/3/100/100',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/parent/settings/');
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
                  context.go('/parent/settings/friend/request');
                },
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(child['imageUrl']!),
                  ),
                  title: Text(child['name']!),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${child['name']}을 눌렀습니다')),
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