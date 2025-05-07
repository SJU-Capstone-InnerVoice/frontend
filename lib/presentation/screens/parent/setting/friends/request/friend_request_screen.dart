import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inner_voice/logic/providers/user/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../../../../../core/constants/api/friends_api.dart';
import '../../../../../../logic/providers/network/dio_provider.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key});

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  late final Dio _dio;
  final TextEditingController _controller = TextEditingController();

  Map<String, dynamic>? _searchResult;
  String? _error;
  bool _isSearching = false;

  @override
  void initState(){
    super.initState();
    _dio = context.read<DioProvider>().dio;
  }

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
      final response = await _dio.get(
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


  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 요청'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
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
                    onPressed: () => userProvider.requestFriend(
                      dio: _dio,
                      friendId: _searchResult!['id'],
                      friendName: _searchResult!['name'],
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