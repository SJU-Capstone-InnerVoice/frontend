// core/constants/api/summary_api.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SummaryApi {
  static final String baseUrl = dotenv.env['SUMMARY_URL'] ?? '';

  static String summary = '$baseUrl/dummy-data';
}