import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inner_voice/logic/providers/user/user_provider.dart';
import 'package:inner_voice/presentation/widgets/show_flushbar.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../../../../../core/constants/api/friends_api.dart';
import '../../../../../../logic/providers/network/dio_provider.dart';
import 'package:another_flushbar/flushbar.dart';

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
  void initState() {
    super.initState();
    _dio = context
        .read<DioProvider>()
        .dio;
  }

  Future<void> _searchFriend(Future<Map<String,
      dynamic>?> Function(String name) searchFriendCallback,) async {
    final String friendName = _controller.text.trim();
    if (friendName.isEmpty) return;

    bool isExist =
    context.read<UserProvider>().isFriendAlreadyAddedByName(friendName);
    if (isExist) {
      String message = "이미 등록된 아이입니다.";
      showIVFlushbar(
        context,
        message,
        position: FlushbarPosition.BOTTOM,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      );
      return;
    }

    debugPrint('🔍 검색 시작: $friendName');

    setState(() {
      _isSearching = true;
      _error = null;
      _searchResult = null;
    });

    try {
      final result = await searchFriendCallback(friendName);

      if (result != null) {
        setState(() {
          _searchResult = result;
        });
        debugPrint('✅ 친구 찾음: id=${result['id']}, name=${result['name']}');
      } else {
        setState(() {
          _error = '해당 이름의 친구를 찾을 수 없습니다.';
        });
        debugPrint('❌ 친구 없음');
      }
    } catch (e) {
      setState(() {
        _error = '검색 중 오류가 발생했습니다.';
      });
      debugPrint('❗ 검색 중 오류: $e');
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
        title: const Text('아이 등록'),
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
                      hintText: '자녀 이름을 입력해주세요.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSearching
                      ? null
                      : () =>
                      _searchFriend(
                            (name) =>
                            userProvider.searchFriend(
                              dio: _dio,
                              friendName: name,
                            ),
                      ),
                  child: const Text('검색'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isSearching)
              const CircularProgressIndicator()
            else
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red))
              else
                if (_searchResult != null)
                  ListTile(
                    title: Text(_searchResult!['name']),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        final name = _searchResult!['name'];
                        final id = _searchResult!['id'];

                        await userProvider.requestFriend(
                          dio: _dio,
                          friendId: id,
                          friendName: name,
                        );

                        setState(() {
                          _searchResult = null;
                          _controller.clear();
                        });
                        showIVFlushbar(context, '$name님에게 친구 요청을 보냈습니다.',
                          position: FlushbarPosition.BOTTOM,
                          icon: const Icon(
                              Icons.person_add_alt_1, color: Colors.white),
                        );
                      },
                      child: const Text('추가'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
