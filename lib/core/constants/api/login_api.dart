// core/constants/api/login_api.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginApi {
  static final String baseUrl = dotenv.env['BACKEND_URL'] ?? '';

  static String login = '$baseUrl/users/login';     // POST
  static String register = '$baseUrl/users';        // POST
}
