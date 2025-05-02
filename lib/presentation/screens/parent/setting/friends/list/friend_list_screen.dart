import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../../logic/providers/network/dio_provider.dart';
import '../../../../../../core/constants/api/friends_api.dart';
import '../../../../../../data/models/friend_model.dart';

class FriendListScreen extends StatefulWidget {
  const FriendListScreen({super.key});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  late final _dio;
  List<Friend> _friends = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _dio = context.read<DioProvider>().dio;

    _fetchFriends();
  }

  Future<void> _fetchFriends() async {
    try {
      final response = await _dio.get(
        FriendsApi.getFriends,
        queryParameters: {'userId': 2}, // 실제 사용자 ID로 변경
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          _friends = data.map((e) => Friend.fromJson(e)).toList();
          _isLoading = false;
        });
        debugPrint('👤 친구 목록 불러오기 완료');
        for (final friend in _friends) {
          debugPrint('ID: ${friend.friendId}, 이름: ${friend.friendName}');
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('에러 발생: $_error'))
          : Column(
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
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://picsum.photos/seed/${friend.friendId}/100/100',
                    ),
                  ),
                  title: Text(friend.friendName),
                  trailing:
                  const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${friend.friendName}을 눌렀습니다')),
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