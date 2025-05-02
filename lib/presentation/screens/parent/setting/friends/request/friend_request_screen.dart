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

  Map<String, dynamic>? _searchResult;
  String? _error;
  bool _isSearching = false;

  Future<void> _searchFriend() async {
    final String friendName = _controller.text.trim();
    if (friendName.isEmpty) return;

    debugPrint('🔍 검색 시작: $friendName');

    setState(() {
      _isSearching = true;
      _error = null;
      _searchResult = null;
    });

    try {
      final response = await dio.get(
        FriendsApi.searchFriend,
        queryParameters: {'name': friendName},
      );

      debugPrint('📥 검색 응답: ${response.data}');

      if (response.statusCode == 200 && response.data['id'] != null) {
        setState(() {
          _searchResult = response.data;
        });
        debugPrint('✅ 친구 찾음: id=${response.data['id']}, name=${response.data['name']}');
      } else {
        setState(() {
          _error = '해당 이름의 친구를 찾을 수 없습니다.';
        });
        debugPrint('❌ 친구 없음');
      }
    } catch (e) {
      if (e is DioError && e.response?.data['code'] == 2002) {
        setState(() {
          _error = '해당 이름의 친구를 찾을 수 없습니다.';
        });
        debugPrint('⚠️ 검색 실패 - code 2002 (친구 없음)');
      } else {
        setState(() {
          _error = '검색 중 오류가 발생했습니다.';
        });
        debugPrint('❗ 검색 중 오류: $e');
      }
    } finally {
      setState(() {
        _isSearching = false;
      });
      debugPrint('🔍 검색 종료');
    }
  }

  Future<void> _sendFriendRequest(int friendId, String friendName) async {
    const int userId = 1; // TODO: 실제 로그인 사용자 ID로 교체

    debugPrint('📨 친구 요청 시작 → userId: $userId, friendId: $friendId ($friendName)');

    try {
      final response = await dio.post(
        FriendsApi.requestFriends,
        data: {
          'userId': userId,
          'friendId': friendId,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      debugPrint('📥 요청 응답: ${response.data}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$friendName님에게 친구 요청을 보냈습니다.')),
        );
        setState(() {
          _searchResult = null;
          _controller.clear();
        });
        debugPrint('✅ 친구 요청 성공');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('친구 요청 실패')),
        );
        debugPrint('❌ 친구 요청 실패 - status: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('요청 중 오류가 발생했습니다.')),
      );
      debugPrint('❗ 친구 요청 중 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 요청'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/parent/settings/friend/list');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: '친구 이름',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSearching ? null : _searchFriend,
                  child: const Text('검색'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isSearching)
              const CircularProgressIndicator()
            else if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red))
            else if (_searchResult != null)
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://picsum.photos/seed/${_searchResult!['id']}/100/100',
                    ),
                  ),
                  title: Text(_searchResult!['name']),
                  trailing: ElevatedButton(
                    onPressed: () => _sendFriendRequest(
                      _searchResult!['id'],
                      _searchResult!['name'],
                    ),
                    child: const Text('추가'),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}