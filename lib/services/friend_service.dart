import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../core/constants/api/friends_api.dart';
import '../data/models/friend/friend_model.dart';
import '../data/models/friend/friend_request_model.dart';

class FriendService {
  Future<List<Friend>> queryFriendsList({
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
  Future<Response> sendFriendRequest({
    required Dio dio,
    required int userId,
    required int friendId,
    required String friendName,
  }) async {
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
      return response;
    } catch (e) {
      debugPrint('❗ 친구 요청 중 오류: $e');
      rethrow;
    }
  }
  Future<Map<String, dynamic>?> searchFriendByName({
    required Dio dio,
    required String name,
  }) async {
    debugPrint('🔍 검색 시작: $name');

    try {
      final response = await dio.get(
        FriendsApi.searchFriend,
        queryParameters: {'name': name},
      );

      debugPrint('📥 검색 응답: ${response.data}');

      if (response.statusCode == 200 && response.data['id'] != null) {
        debugPrint('✅ 친구 찾음: id=${response.data['id']}, name=${response.data['name']}');
        return response.data;
      } else {
        debugPrint('❌ 친구 없음');
        return null;
      }
    } on DioError catch (e) {
      if (e.response?.data['code'] == 2002) {
        debugPrint('⚠️ 검색 실패 - code 2002 (친구 없음)');
        return null;
      } else {
        debugPrint('❗ 검색 중 Dio 오류: $e');
        rethrow;
      }
    } catch (e) {
      debugPrint('❗ 검색 중 일반 오류: $e');
      rethrow;
    } finally {
      debugPrint('🔍 검색 종료');
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