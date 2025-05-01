// core/constants/api/character_img_api.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CharacterImgApi {
  static final String baseUrl = dotenv.env['BACKEND_URL'] ?? '';

  static String getCharacterImg(String userId) => '$baseUrl/characters?userId=$userId';
  static String uploadCharacterImg = '$baseUrl/characters'; // post
}