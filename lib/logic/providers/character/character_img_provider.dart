import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class CharacterImgProvider extends ChangeNotifier {
  // userId → characterId → imageUrl
  final Map<String, Map<String, String>> _imageUrls = {};
  final Dio _dio = Dio();

  Map<String, Map<String, String>> get imageUrls => _imageUrls;

  /// 서버에 이미지 업로드 후 URL만 저장
  Future<String?> uploadImage(String userId, String characterId, File file) async {
    try {
      const uploadUrl = 'https://your.api.com/upload'; // 실제 서버 URL로 교체

      FormData formData = FormData.fromMap({
        'userId': userId,
        'characterId': characterId,
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      });

      Response response = await _dio.post(uploadUrl, data: formData);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final String imageUrl = response.data['url'];

        _imageUrls.putIfAbsent(userId, () => {});
        _imageUrls[userId]![characterId] = imageUrl;

        notifyListeners();
        return imageUrl; // ✅ URL 반환
      } else {
        throw Exception('서버 업로드 실패: ${response.data}');
      }
    } catch (e) {
      print('❌ 이미지 업로드 실패: $e');
      return null;
    }
  }

  /// 이미지 URL 조회
  String? getImageUrl(String userId, String characterId) {
    return _imageUrls[userId]?[characterId];
  }
}