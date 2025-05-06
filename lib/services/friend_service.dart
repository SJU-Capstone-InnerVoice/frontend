import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../core/constants/api/friends_api.dart';
import '../data/models/user/child_model.dart';

class FriendService {
  Future<List<Child>> queryChildList({
    required Dio dio,
    required String userId,
  }) async {
    try {
      final response = await dio.get(
        FriendsApi.getFriends,
        queryParameters: {'userId': userId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        final friends = data.map((e) => Child.fromJson(e)).toList();

        debugPrint('✅ 친구 목록 조회 성공: ${friends.length}명');
        for (final friend in friends) {
          debugPrint('🧒 ID: ${friend.id}, 이름: ${friend.name}');
        }

        return friends;
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 친구 조회 실패: $e');
      rethrow;
    }
  }
}