// core/constants/api/friends_api.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FriendsApi {
  static final String baseUrl = dotenv.env['BACKEND_URL'] ?? '';

  static String requestFriends = '$baseUrl/friends/requests';
}