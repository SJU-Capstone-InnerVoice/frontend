// core/constants/api/friends_api.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FriendsApi {
  static final String baseUrl = dotenv.env['BACKEND_URL'] ?? '';

  static String getFriends = '$baseUrl/friends';
  static String requestFriends = '$baseUrl/friends/request';
  static String searchFriend = '$baseUrl/friends/search';
  static String checkRequestFriends = '$baseUrl/friends/requests';
  static String acceptRequestFriends(int requestId) =>
      '$baseUrl/friends/requests/$requestId/accept';
}

class QueryKeys {
  static const String userId = 'userId';
}