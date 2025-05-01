import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class CharacterImgProvider extends ChangeNotifier {
  final Map<String, Map<String, Image>> _images = {};
  final Dio _dio = Dio();

  Map<String, Map<String, Image>> get images => _images;

  /// 서버에 이미지 업로드 후 로컬에 저장
  Future<void> uploadImage(String userId, String characterId, File file) async {
    try {
      // 1. 서버로 업로드
      String uploadUrl = 'https://your.api.com/upload'; // 실제 서버 URL로 변경
      FormData formData = FormData.fromMap({
        'userId': userId,
        'characterId': characterId,
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      });

      Response response = await _dio.post(uploadUrl, data: formData);

      if (response.statusCode == 200 && response.data['success'] == true) {
        // 2. 성공 시 로컬에도 저장
        _images.putIfAbsent(userId, () => {});
        _images[userId]![characterId] = Image.file(file);
        notifyListeners();
      } else {
        throw Exception('서버 업로드 실패: ${response.data}');
      }
    } catch (e) {
      print('❌ 이미지 업로드 실패: $e');
    }
  }
}