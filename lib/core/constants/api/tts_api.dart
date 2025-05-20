// core/constants/api/tts_api.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TtsAPI {
  static final String baseUrl = dotenv.env['TTS_URL'] ?? '';
  static final String requestTTS = '$baseUrl/synthesize';
}