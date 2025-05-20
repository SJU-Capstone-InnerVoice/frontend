import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/constants/api/character_img_api.dart';
import '../../../data/models/character/character_image_model.dart';

class CharacterImgProvider extends ChangeNotifier {
  final Dio _dio;
  bool _hasLoaded = false;
  final Map<String, List<CharacterImage>> _userCharacters = {};
  bool _isDisposed = false;

  CharacterImgProvider(this._dio);
  bool get isDisposed => _isDisposed;

  List<CharacterImage> getCharacters(String userId) => _userCharacters[userId] ?? [];
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
  void resetLoadState() {
    _hasLoaded = false;
  }
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
    notifyListeners();
  }

  Future<void> loadImagesFromServer(String userId) async {

    try {
      final String fetchUrl = CharacterImgApi.getCharacterImg(userId);
      Response response = await _dio.get(fetchUrl);

      if (response.statusCode == 200) {
        final List<CharacterImage> characterList =
        (response.data as List)
            .map((item) => CharacterImage.fromJson(item))
            .toList();

        _userCharacters[userId] = characterList;

        for (final character in characterList) {
          print('🖼 characterId: ${character.id}');
          print('🌐 imageUrl: ${character.imageUrl}');
          print(" name: ${character.name}");
        }

        if (!_isDisposed) notifyListeners(); // ✅ 성공 시
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 이미지 로딩 실패: $e');
      if (!_isDisposed) notifyListeners(); // ✅ 실패 시
    }
  }

  /// 아이의 call start 화면에 띄우기 위한 메소드
  Future<CharacterImage?> loadImageByCharacterId({
    required String userId,
    required String characterId,
  }) async {
    try {
      final String fetchUrl = CharacterImgApi.getCharacterImg(userId);
      final Response response = await _dio.get(fetchUrl);

      if (response.statusCode == 200) {
        final List<CharacterImage> characterList =
        (response.data as List).map((item) => CharacterImage.fromJson(item)).toList();

        _userCharacters[userId] = characterList;
        notifyListeners();

        final result = characterList.firstWhere(
              (character) => character.id == characterId,
        );

        if (result.id == '') return null;
        return result;
      } else {
        throw Exception('❌ 서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 단일 캐릭터 필터링 실패: $e');
      return null;
    }
  }
}