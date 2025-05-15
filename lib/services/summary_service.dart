// lib/services/summary_service.dart

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:http_parser/http_parser.dart';
import '../../core/constants/api/summary_api.dart';
import '../../data/models/summary/summary_model.dart';

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

      final response = await _dio.post(
        serverUrl,
        data: formData,
      ).timeout(const Duration(seconds: 5));

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

  Future<void> uploadSummary(CounselingSummary summary, int parentId) async {
    final serverUrl = "http://54.180.199.57:8080/talks";

    try {
      final data = {
        ...summary.toJson(),
        'userId': parentId,
      };

      print('📤 요약 업로드 시작: $data');

      final response = await _dio.post(
        serverUrl,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ 요약 업로드 성공');
      } else {
        print('❌ 요약 업로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 업로드 중 오류 발생: $e');
    }
  }

  Future<List<CounselingSummary>> getSummaries(int userId) async {
    final serverUrl = "http://54.180.199.57:8080/talks?userId=$userId";
    try {
      final response = await _dio.get(serverUrl);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final summaries = data.map((json) => CounselingSummary.fromJson(json)).toList();
        print('✅ 서버에서 요약 ${summaries.length}개 가져옴');
        return summaries;
      } else {
        print('❌ 서버 오류: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('🚨 서버 통신 실패: $e');
      return [];
    }
  }
}
