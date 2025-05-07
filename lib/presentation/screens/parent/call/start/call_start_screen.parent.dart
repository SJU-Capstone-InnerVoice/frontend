import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import '../../../../../logic/providers/communication/call_session_provider.dart';

class CallStartScreen extends StatefulWidget {
  const CallStartScreen({super.key});

  @override
  State<CallStartScreen> createState() => _CallStartScreenState();
}

class _CallStartScreenState extends State<CallStartScreen> {
  final TextEditingController _controller = TextEditingController();
  late final CallSessionProvider _callSession;

  final List<Map<String, String>> _messages = [
    {'time': '11:50', 'type': 'user', 'text': '오늘 하루 어땠어?'},
    {
      'time': '11:51',
      'type': 'user',
      'text': '네가 소중한 사람이라서 이렇게 이야기 하고 싶어. 같이 해결해보자.'
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _callSession = context.read<CallSessionProvider>();
  }

  _onSendPressed() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      _callSession.rtcService.sendChatMessage(text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    print("CallStartScreen dispose 실행됨");
    _controller.dispose();
    _callSession.disposeCall();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 🔵 상단 영상
            ValueListenableBuilder<MediaStream?>(
                valueListenable: _callSession.remoteStreamNotifier,
                builder: (context, stream, _) {
                  final rtc = _callSession.rtcService;
                  print("📡 remoteStream: $stream");
                  print(
                      "📡 remoteRenderer.srcObject: ${rtc.remoteRenderer.srcObject}");

                  if (!rtc.initialized) {
                    return const Center(child: Text('영상 초기화 중입니다...'));
                  }

                  return AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.black12,
                          child: RTCVideoView(rtc.remoteRenderer),
                        ),
                      ],
                    ),
                  );
                }),

            // 🔴 전화 끊기 버튼
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: IconButton(
                iconSize: 48,
                icon: const Icon(Icons.call_end, color: Colors.white),
                onPressed: () {
                  context.pop();
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: const CircleBorder(),
                ),
              ),
            ),

            // 💬 채팅 메시지 리스트 (스크롤 되는 부분)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      '2025년 3월 15일 토요일\n아이가 입장하였습니다',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final msg in _messages)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              msg['text']!,
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              msg['time']!,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ✍️ 입력창 + 전송 버튼 (고정)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: '메시지 입력',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                    onPressed: _onSendPressed,
                    child: const Text('전송'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
