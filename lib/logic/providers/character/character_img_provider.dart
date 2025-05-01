import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class CharacterImgProvider extends ChangeNotifier {
  // userId → characterId → Image 위젯
  final Map<String, Map<String, Image>> _imageWidgets = {};
  final Dio _dio = Dio();

  Map<String, Map<String, Image>> get imageWidgets => _imageWidgets;

  /// 서버에 이미지 업로드 후 Image 위젯으로 저장
  // Future<Image?> uploadImage(String userId, String characterId, File file) async {
  //   try {
  //     const uploadUrl = 'https://your.api.com/upload'; // 실제 서버 URL로 교체
  //
  //     FormData formData = FormData.fromMap({
  //       'userId': userId,
  //       'characterId': characterId,
  //       'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
  //     });
  //
  //     Response response = await _dio.post(uploadUrl, data: formData);
  //
  //     if (response.statusCode == 200 && response.data['success'] == true) {
  //       final String imageUrl = response.data['url'];
  //
  //       _imageWidgets.putIfAbsent(userId, () => {});
  //       _imageWidgets[userId]![characterId] = Image.network(imageUrl);
  //
  //       notifyListeners();
  //       return _imageWidgets[userId]![characterId]; // ✅ Image 반환
  //     } else {
  //       throw Exception('서버 업로드 실패: ${response.data}');
  //     }
  //   } catch (e) {
  //     print('❌ 이미지 업로드 실패: $e');
  //     return null;
  //   }
  // }

  /// 서버에서 이미지 불러오기 (초기 로딩용)
  Future<void> loadImagesFromServer(String userId) async {
    try {
      final String fetchUrl = 'https://your.api.com/images?userId=$userId';
      Response response = await _dio.get(fetchUrl);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

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