// core/constants/api/summary_api.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SummaryApi {
  static final String baseUrl = dotenv.env['SUMMARY_URL'] ?? '';
  static final String baseUrl2 = dotenv.env['SUMMARY_URL2'] ?? '';

  static String querySummary = '$baseUrl/dummy-data';
  static String requestsummary = '$baseUrl2/transcribe_and_respond';
}