// lib/services/summary_service.dart

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:http_parser/http_parser.dart';
import '../../core/constants/api/summary_api.dart';

class SummaryService {
  final Dio _dio = Dio();

  Future<Map<String, String>?> uploadAudioAndGetSummary(String filePath) async {
    final serverUrl = SummaryApi.requestsummary;

    try {
      final fileName = p.basename(filePath);
      print('🌐 서버 요청 URL: $serverUrl');
      print('📂 전송 파일 경로: $filePath');
      print('📎 파일 이름: $fileName');

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: MediaType('audio', 'wav'),
        ),
      });

      final response = await _dio.post(serverUrl, data: formData);

      if (response.statusCode == 200) {
        final data = response.data;
        final summary = data['summary'];
        return {
          'title': summary['title'] ?? '',
          'content': summary['content'] ?? '',
        };
      } else {
        print('❌ 서버 응답 오류: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('🚨 전송 실패: $e');
      return null;
    }
  }
}