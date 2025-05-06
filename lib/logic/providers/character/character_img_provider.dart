import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/constants/api/character_img_api.dart';
import '../../../data/models/character/character_image_model.dart';

class CharacterImgProvider extends ChangeNotifier {
  final Dio _dio;
  bool _hasLoaded = false;
  final Map<String, List<CharacterImage>> _userCharacters = {};

  CharacterImgProvider(this._dio);

  List<CharacterImage> getCharacters(String userId) => _userCharacters[userId] ?? [];

  Future<void> uploadImage({
    required dynamic userId,
    required String name,
    required String type,
    required File file,
  }) async {
    try {
      final String uploadUrl = CharacterImgApi.uploadCharacterImg;

      FormData formData = FormData.fromMap({
        'userId': userId.toString(),
        'name': name,
        'type': type,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      Response response = await _dio.post(uploadUrl, data: formData);

      if (response.statusCode == 200) {
        print('✅ 이미지 업로드 성공');
        _hasLoaded = false;
      } else {
        throw Exception('🚫 서버 업로드 실패: ${response.data}');
      }
    } catch (e) {
      print('❌ 이미지 업로드 실패: $e');
    }
  }

  Future<void> loadImagesFromServer(String userId) async {
    if (_hasLoaded) return;
    _hasLoaded = true;

    try {
      final String fetchUrl = CharacterImgApi.getCharacterImg(userId);
      Response response = await _dio.get(fetchUrl);

      if (response.statusCode == 200) {
        final List<CharacterImage> characterList =
        (response.data as List).map((item) => CharacterImage.fromJson(item)).toList();

        _userCharacters[userId] = characterList;

        for (final c in characterList) {
          print('🖼 characterId: ${c.id}');
          print('🌐 imageUrl: ${c.imageUrl}');
          print(" name: ${c.name}");
        }

        notifyListeners();
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 이미지 로딩 실패: $e');
    }
  }
}