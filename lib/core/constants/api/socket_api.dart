// core/constants/api/socket_api.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocketAPI {
  static final String baseUrl = dotenv.env['SOCKET_URL'] ?? '';
  static final String stun = dotenv.env['STUN_URL'] ?? '';
}