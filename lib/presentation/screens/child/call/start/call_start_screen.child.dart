import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../logic/providers/communication/call_session_provider.dart';
class CallStartScreen extends StatefulWidget {
  const CallStartScreen({super.key});

  @override
  State<CallStartScreen> createState() => _CallStartScreenState();
}

class _CallStartScreenState extends State<CallStartScreen> {
  late final CallSessionProvider _callSession;
  String? _lastSpoken;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _callSession = context.read<CallSessionProvider>();
  }

  @override
  void dispose() {
    print("CallStartScreen dispose 실행됨");
    _callSession.disposeCall();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 🔁 TTS용 Consumer (UI에 표시되지 않음)
            Consumer<CallSessionProvider>(
              builder: (context, session, _) {
                final messages = session.messages;

                if (messages.isNotEmpty) {
                  final latest = messages.last;

                  if (latest != _lastSpoken) {
                    _lastSpoken = latest;
                    print("리스트: $messages");
                    Future.microtask(() {
                      // _speak(latest);
                    });
                  }
                }

                return const SizedBox.shrink();
              },
            ),
            Column(
              children: [
                const Spacer(),

                // 🖼️ 가운데 랜덤 이미지
                Center(
                  child: Container(
                    width: 220,
                    height: 304,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black12,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      'https://picsum.photos/200/305',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const Spacer(),

                // 🔴 전화 끊기 버튼
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: IconButton(
                    icon: const Icon(Icons.call_end, color: Colors.white),
                    iconSize: 48,
                    onPressed: () {
                      Navigator.pop(context,true);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}