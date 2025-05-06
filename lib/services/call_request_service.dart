import 'package:dio/dio.dart';
import '../../../../core/constants/api/call_request_api.dart';

class CallRequestService {
  final Dio dio;
  CallRequestService({required this.dio});

  Future<Map<String, dynamic>> createCallRequest({
    required int userId,
    required int receiverId,
    required int characterId,
    required int roomId,
  }) async {
    try {
      final response = await dio.post(
        CallRequestAPI.createCallRequest,
        data: {
          'userId': userId,
          'receiverId': receiverId,
          'characterImageId': characterId,
          'roomId': roomId,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        print('📞 통화 요청 생성 성공!');
        print('응답 데이터: ${response.data}');
        return response.data;
      } else {
        throw Exception('⚠️ 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 통화 요청 중 오류 발생: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> queryCallRequest({required int userId}) async {
    try {
      final response = await dio.get(
        CallRequestAPI.queryCallRequest,
        queryParameters: {'userId': userId},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        print('📨 통화 요청 조회 성공: ${response.data.last}');
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('❗ 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 통화 요청 조회 실패: $e');
      rethrow;
    }
  }
  Future<void> acceptCallRequest({required int requestId}) async {
    try {
      final response = await dio.patch(
        CallRequestAPI.acceptCallRequest(requestId),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        print('✅ 통화 요청 수락 완료!');
      } else {
        throw Exception('❌ 수락 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 수락 중 오류 발생: $e');
      rethrow;
    }
  }
  Future<void> deleteCallRequest({
    required int requestId,
  }) async {
    try {
      final response = await dio.delete(
        CallRequestAPI.deleteCallRequest(requestId),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200) {
        print('🗑️ 통화 요청 삭제 성공: ID=$requestId');
      } else {
        throw Exception('⚠️ 삭제 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 통화 요청 삭제 중 오류 발생: $e');
      rethrow;
    }
  }
}
