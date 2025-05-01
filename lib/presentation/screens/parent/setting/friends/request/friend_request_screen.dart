import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../../../core/constants/api/friends_api.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key});

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  final TextEditingController _controller = TextEditingController();
  final Dio dio = Dio();

  Future<void> _sendFriendRequest() async {
    final String friendIdText = _controller.text.trim();

    if (friendIdText.isEmpty) return;

    try {
      final int friendId = int.parse(friendIdText);
      const int userId = 1; // TODO: 실제 로그인 사용자 ID로 교체 필요
      print(FriendsApi.requestFriends);

      final response = await dio.post(
        FriendsApi.requestFriends,
        data: {
          'userId': userId,
          'friendId': friendId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('✅ 친구 요청 성공: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$friendId에게 친구 요청을 보냈습니다.')),
        );
        _controller.clear();
      } else {
        print('⚠️ 친구 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 요청 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('요청 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/parent/settings/friend/list');
          },
        ),
        title: const Text('친구 요청'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: '친구 ID',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _sendFriendRequest,
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }
}