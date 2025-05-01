import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/constants/api/character_img_api.dart';

class CharacterImgProvider extends ChangeNotifier {
  // userId → characterId → Image 위젯
  final Map<String, Map<String, Image>> _imageWidgets = {};
  final Dio _dio = Dio();

  Map<String, Map<String, Image>> get imageWidgets => _imageWidgets;

  Future<Image?> uploadImage({
    required String userId,
    required String name,
    required String type,
    required File file,
  }) async {
    try {
      final String uploadUrl = CharacterImgApi.uploadCharacterImg;

      FormData formData = FormData.fromMap({
        'userId': userId,
        'name': name,
        'type': type,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });
      print('📦 FormData 필드 목록:');
      for (var field in formData.fields) {
        print('  ${field.key} : ${field.value}');
      }

      print('📦 FormData 파일 목록:');
      for (var file in formData.files) {
        print('  ${file.key} : ${file.value.filename}');
      }

      Response response = await _dio.post(uploadUrl, data: formData);
      if (response.statusCode == 200) {
        final String imageUrl = response.data['url'];

        _imageWidgets.putIfAbsent(userId, () => {});
        _imageWidgets[userId]![name] = Image.network(imageUrl);

        notifyListeners();
        return _imageWidgets[userId]![name];
      } else {
        throw Exception('서버 업로드 실패: ${response.data}');
      }

    } catch (e) {
      print('❌ 이미지 업로드 실패: $e');
      return null;
    }
  }
  /// 서버에서 이미지 불러오기 (초기 로딩용)
  Future<void> loadImagesFromServer(String userId) async {
    try {
      final String fetchUrl = CharacterImgApi.getCharacterImg(userId);
      Response response = await _dio.get(fetchUrl);
      print(fetchUrl);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print(data);
        for (var item in data) {
          final String characterId = item['id'].toString();
          final String imageUrl = item['imageUrl'];

          print('🖼 characterId: $characterId');
          print('🌐 imageUrl: $imageUrl');

          _imageWidgets[userId]![characterId] = Image.network(imageUrl);
        }
        _imageWidgets[userId] = {};

        for (var item in data) {
          final String characterId = item['id'].toString();
          final String imageUrl = item['imageUrl'];

          _imageWidgets[userId]![characterId] = Image.network(imageUrl);
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