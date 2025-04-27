import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../../core/constants/api/polling_api.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final Dio dio = Dio();
  final String baseUrl = PollingAPI.callRequest;
  final String characterId = 'char1';
  final String roomId = 'roomA';
  final String parentId = 'parent001';
  final String childId = 'child001';

  List<dynamic> polledData = [];

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

  Future<void> pollCallRequests() async {
    try {
      final response = await dio.get(PollingAPI.callRequest, queryParameters: {
        'characterId': characterId,
        'roomId': roomId,
      });
      setState(() {
        polledData = response.data['data'];
      });
      print('📥 폴링 결과: $polledData');
    } catch (e) {
      print('❌ 폴링 실패: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call Polling 테스트')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: createCallRequest,
              child: const Text('1. 요청 생성 (부모)'),
            ),
            ElevatedButton(
              onPressed: pollCallRequests,
              child: const Text('2. 요청 폴링 (아이)'),
            ),
            ElevatedButton(
              onPressed: () {updateCallStatus('accepted');pollCallRequests();},
              child: const Text('3. 상태 변경 → 수락 (아이)'),
            ),
            const SizedBox(height: 16),
            const Text('📋 현재 요청 목록:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: polledData.length,
                itemBuilder: (context, index) {
                  final item = polledData[index];
                  return ListTile(
                    title: Text('From: ${item['from']} → To: ${item['to']}'),
                    subtitle: Text('Status: ${item['status']}'),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}