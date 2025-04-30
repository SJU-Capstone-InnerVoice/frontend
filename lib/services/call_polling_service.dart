import 'package:dio/dio.dart';

import '../../../../core/constants/api/polling_api.dart';

class CallPollingService {
  final Dio dio = Dio();
  final String characterId;
  final String roomId;
  final String parentId;
  final String childId;

  CallPollingService({
    required this.characterId,
    required this.roomId,
    required this.parentId,
    required this.childId,
  });

  Future<void> createCallRequest() async {
    try {
      final response = await dio.post(PollingAPI.callRequest, data: {
        'characterId': characterId,
        'roomId': roomId,
        'from': parentId,
        'to': childId,
      });
      print('✅ 요청 생성 완료: ${response.data}');
    } catch (e) {
      print('❌ 요청 생성 실패: $e');
    }
  }

  Future<List<dynamic>> pollCallRequests() async {
    try {
      final response = await dio.get(PollingAPI.callRequest, queryParameters: {
        'characterId': characterId,
        'roomId': roomId,
      });
      print('📥 폴링 결과: ${response.data['data']}');
      return response.data['data'];
    } catch (e) {
      print('❌ 폴링 실패: $e');
      return [];
    }
  }

  Future<void> updateCallStatus(String newStatus) async {
    try {
      final response = await dio.post(PollingAPI.updateCallStatus, data: {
        'characterId': characterId,
        'roomId': roomId,
        'from': parentId,
        'newStatus': newStatus,
      });
      print('🔧 상태 변경 완료: ${response.data}');
    } catch (e) {
      print('❌ 상태 변경 실패: $e');
    }
  }

  Future<void> deleteCallRequest() async {
    try {
      final response = await dio.delete(PollingAPI.callRequest, data: {
        'characterId': characterId,
        'roomId': roomId,
        'from': parentId,
      });
      print('🗑️ 요청 삭제 성공: ${response.data}');
    } catch (e) {
      print('❌ 요청 삭제 실패: $e');
    }
  }
}