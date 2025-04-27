import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/call_polling_service.dart';
import '../../../../logic/providers/communication/call_polling_provider.dart';
class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final CallPollingService callPollingService;

  @override
  void initState() {
    super.initState();
    callPollingService = CallPollingService(
      characterId: 'char1',
      roomId: 'roomA',
      parentId: 'parent001',
      childId: 'child001',
    );
  }

  Future<void> createCallRequest() async {
    await callPollingService.createCallRequest();
  }

  Future<void> pollCallRequests(BuildContext context) async {
    final data = await callPollingService.pollCallRequests();
    context.read<CallPollingProvider>().updatePolledData(data);
  }

  Future<void> updateCallStatus(BuildContext context, String newStatus) async {
    await callPollingService.updateCallStatus(newStatus);
    await pollCallRequests(context); // 상태 바꾸고 폴링 새로
  }

  @override
  Widget build(BuildContext context) {
    final polledData = context.watch<CallPollingProvider>().polledData;

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
              onPressed: () => pollCallRequests(context),
              child: const Text('2. 요청 폴링 (아이)'),
            ),
            ElevatedButton(
              onPressed: () => updateCallStatus(context, 'accepted'),
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