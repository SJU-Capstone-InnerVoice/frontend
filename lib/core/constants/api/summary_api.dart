// core/constants/api/summary_api.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SummaryApi {
  static final String baseUrl = dotenv.env['BACKEND_URL'] ?? '';
  static final String aiUrl = dotenv.env['AI_URL'] ?? '';

  static final String createSummaryUrl = '$aiUrl/summarize';
  static final String uploadSummaryUrl = '$baseUrl/talks';
  static final String getSummaryUrl = '$baseUrl/talks';


}