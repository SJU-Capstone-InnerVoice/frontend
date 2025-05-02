import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/call_polling_service.dart';
import '../../../../logic/providers/communication/call_session_provider.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final CallPollingService callPollingService;
  bool hasCallRequest = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    callPollingService = CallPollingService(
      characterId: 'char1',
      roomId: 'roomA',
      parentId: 'parent001',
      childId: 'child001',
    );
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      await pollCallRequest();
    });
  }

  Future<void> pollCallRequest() async {
    final data = await callPollingService.pollCallRequests();
    setState(() {
      hasCallRequest = data.isNotEmpty;
    });
  }

  Future<void> acceptCallRequest() async {
    _pollingTimer?.cancel();
    await callPollingService.updateCallStatus('accepted');
    final data = await callPollingService.pollCallRequests();
    setState(() {
      hasCallRequest = data.isNotEmpty;
    });
    final rtcService = context.read<CallSessionProvider>().rtcService;
    await rtcService.init(
      isCaller: true,
      roomId: 1,
      onMessage: (message) {
        print("📩 받은 메시지: $message");
      },
    );
    context.push('/check/call/start').then((_) {
      // 돌아왔을 때 polling 재시작 + UI 갱신
      _startPolling();
      pollCallRequest();
    });
  }
  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Center(
                child: Text(
                  hasCallRequest ? '대화 요청이 왔어요!' : '대화 요청이 없어요',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '대화방 이름',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '캐릭터 정보',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // ✅ 대화 하고 싶어요 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: hasCallRequest ? acceptCallRequest : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    '대화 하고 싶어요!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}