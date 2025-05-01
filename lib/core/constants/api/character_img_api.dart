// core/constants/api/character_img_api.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PollingAPI {
  static final String baseUrl = dotenv.env['BACKEND_URL'] ?? '';
  static final String character = '$baseUrl/character';
}