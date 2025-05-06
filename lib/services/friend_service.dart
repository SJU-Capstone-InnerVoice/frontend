import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../core/constants/api/friends_api.dart';
import '../data/models/friend/friend_model.dart';
import '../data/models/friend/friend_request_model.dart';

class FriendService {
  Future<List<Friend>> queryChildList({
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

        final friends = data.map((e) => Friend.fromJson(e)).toList();

        debugPrint('✅ 친구 목록 조회 성공: ${friends.length}명');
        for (final friend in friends) {
          debugPrint('🧒 ID: ${friend.friendId}, 이름: ${friend.friendName}');
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
  static Future<List<FriendRequest>> queryRequestList({
    required Dio dio,
    required String userId,
  }) async {
    try {
      final response = await dio.get(
        FriendsApi.checkRequestFriends,
        queryParameters: {'userId': userId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final requests = data.map((e) => FriendRequest.fromJson(e)).toList();

        print('✅ 요청 목록 조회 성공: ${requests.length}건');
        for (final request in requests) {
          print('📬 요청 index: ${request.requestId}, 보낸 사람: ${request.userName}, 보낸 사람 ID: ${request.userId}');
        }

        return requests;
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 요청 조회 실패: $e');
      rethrow;
    }
  }
}