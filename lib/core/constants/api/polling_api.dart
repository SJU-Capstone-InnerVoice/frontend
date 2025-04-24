// core/constants/api/polling_api.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PollingAPI {
  static final String baseUrl = dotenv.env['POLLING_URL'] ?? '';
  static final String fetchStatus = '$baseUrl/status';
  static final String syncData = '$baseUrl/sync';
}