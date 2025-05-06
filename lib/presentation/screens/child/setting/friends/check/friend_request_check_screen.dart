import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    _dio = context.read<DioProvider>().dio;
    _user = context.read<UserProvider>().user!;
    _loadFriendRequests();
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
        queryParameters: {QueryKeys.userId: 2},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        // 수락 성공 시, 해당 요청 제거
        setState(() {
          _requests.removeWhere((r) => r.requestId == requestId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('요청을 수락했습니다.')),
        );
      } else {
        throw Exception('수락 실패: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      print(_error);
      return Center(child: Text('에러 발생: $_error'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 요청 확인'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/child/settings/');
          },
        ),
      ),
      body: _requests.isEmpty
          ? const Center(child: Text('📭 요청이 없습니다.'))
          : ListView.builder(
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final request = _requests[index];
                return ListTile(
                  leading: Text('${request.requestId}'),
                  title: Text(request.userName),
                  subtitle: Text('User ID: ${request.userId}'),
                  trailing: ElevatedButton(
                    onPressed: () => acceptRequest(request.requestId),
                    child: const Text('수락'),
                  ),
                );
              },
            ),
    );
  }
}
