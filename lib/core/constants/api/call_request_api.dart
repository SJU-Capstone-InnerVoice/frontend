// core/constants/api/CallRequest_api.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CallRequestAPI {
  static final String baseUrl = dotenv.env['POLLING_URL'] ?? '';
  static final String createCallRequest = '$baseUrl/conversations';
  static String deleteCallRequest(int id) => '$baseUrl/conversations/$id';
}