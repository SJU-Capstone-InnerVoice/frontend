import 'package:flutter/material.dart';

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
      appBar: AppBar(title: const Text('친구 목록')),
      body: ListView.builder(
        itemCount: children.length,
        itemBuilder: (context, index) {
          final child = children[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(child['imageUrl']!),
            ),
            title: Text(child['name']!),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // 상세 페이지로 이동하거나 대화 시작 등
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${child['name']}을 눌렀습니다')),
              );
            },
          );
        },
      ),
    );
  }
}