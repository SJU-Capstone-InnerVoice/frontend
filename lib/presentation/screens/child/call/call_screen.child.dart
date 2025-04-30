import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/call_polling_service.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final CallPollingService callPollingService;
  bool hasCallRequest = false;

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

  Future<void> pollCallRequest() async {
    final data = await callPollingService.pollCallRequests();
    setState(() {
      hasCallRequest = data.isNotEmpty;
    });
  }

  Future<void> acceptCallRequest() async {
    await callPollingService.updateCallStatus('accepted');
    final data = await callPollingService.pollCallRequests();
    setState(() {
      hasCallRequest = data.isNotEmpty;
    });
    context.go('/child/call/call-start');
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

              // ✅ 갱신 버튼
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: pollCallRequest,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    '갱신',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

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