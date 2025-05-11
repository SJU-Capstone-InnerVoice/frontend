import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../../../widgets/show_flushbar.dart';
import '../../../../../../core/constants/api/friends_api.dart';
import '../../../../../../data/models/friend/friend_request_model.dart';
import '../../../../../../logic/providers/network/dio_provider.dart';
import '../../../../../../logic/providers/user/user_provider.dart';
import '../../../../../../services/friend_service.dart';
import '../../../../../../data/models/user/user_model.dart';

class FriendRequestCheckScreen extends StatefulWidget {
  const FriendRequestCheckScreen({super.key});

  @override
  State<FriendRequestCheckScreen> createState() =>
      _FriendRequestCheckScreenState();
}

class _FriendRequestCheckScreenState extends State<FriendRequestCheckScreen> {
  late final Dio _dio;
  late final User _user;
  List<FriendRequest> _requests = [];
  bool _isLoading = true;
  String? _error;
  bool _hasParent = false;
  String? _parentName;

  @override
  void initState() {
    super.initState();
    _dio = context.read<DioProvider>().dio;
    _user = context.read<UserProvider>().user!;
    _checkParentStatusAndLoadRequests();
  }

  Future<void> _checkParentStatusAndLoadRequests() async {
    try {
      final friends = await FriendService().queryFriendsList(
        dio: _dio,
        userId: _user.userId,
      );

      if (friends.isNotEmpty) {
        setState(() {
          _hasParent = true;
          _parentName = friends[0].friendName;
          _isLoading = false;
        });
      } else {
        await _loadFriendRequests(); // 부모가 없을 때만 요청 목록 확인
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFriendRequests() async {
    try {
      final requests = await FriendService.queryRequestList(
        dio: _dio,
        userId: _user.userId,
      );

      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> acceptRequest(int requestId) async {
    try {
      final response = await _dio.post(
        FriendsApi.acceptRequestFriends(requestId),
        queryParameters: {QueryKeys.userId: _user.userId},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _requests.removeWhere((r) => r.requestId == requestId);
        });
        showIVFlushbar(context, '요청을 수락했습니다.',
            icon: const Icon(Icons.sentiment_satisfied_alt),
            position: FlushbarPosition.BOTTOM);
      } else {
        throw Exception('수락 실패: ${response.statusCode}');
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('에러 발생: $_error'));
    }

    if (_hasParent) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('부모 등록 확인'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 300,
                child: Lottie.asset('assets/animations/turtle.json'),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Column(
                  children: [
                    Text(
                      '부모님이 이미 등록되어 있네요!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '대화를 기다려 볼까요?!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_requests.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('부모 등록 확인'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 300,
                height: 300,
                child: Lottie.asset('assets/animations/turtle.json'),
              ),
              const SizedBox(height: 20),
              const Column(
                children: [
                  Text(
                    '아직 요청이 없어요!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '조금만 더 기다려 볼까요?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // 요청 수락 리스트가 있을 경우
    return Scaffold(
      appBar: AppBar(
        title: const Text('부모 등록 확인'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          return ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text('${request.userName} 부모님이 요청했어요'),
            trailing: ElevatedButton(
              onPressed: () {
                acceptRequest(request.requestId);
                _hasParent = true;
              },
              child: const Text('수락'),
            ),
          );
        },
      ),
    );
  }
}
