// core/constants/api/polling_api.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PollingAPI {
  static final String baseUrl = dotenv.env['POLLING_URL'] ?? '';
  static final String callRequest = '$baseUrl/call-request';
  static final String updateCallStatus = '$baseUrl/update-call-status-by-parent';
}