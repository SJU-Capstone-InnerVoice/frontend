// core/constants/api/CallRequest_api.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CallRequestAPI {
  static final String baseUrl = dotenv.env['POLLING_URL'] ?? '';
  static final String callRequest = '$baseUrl/conversations';
  static final String updateCallStatus = '$baseUrl/update-call-status-by-parent';
}