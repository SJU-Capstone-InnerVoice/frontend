import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../../logic/providers/communication/call_session_provider.dart';

class CallStartScreen extends StatefulWidget {
  const CallStartScreen({super.key});

  @override
  State<CallStartScreen> createState() => _CallStartScreenState();
}

class _CallStartScreenState extends State<CallStartScreen> {
  final String todayDate =
      DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(DateTime.now());
  final TextEditingController _controller = TextEditingController();
  late final CallSessionProvider _callSession;
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];


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

      setState(() {
        _messages.add({
          'time': DateFormat('HH:mm').format(DateTime.now()),
          'type': 'user',
          'text': text,
        });
      });

      _controller.clear();

      // 🔽 스크롤을 마지막 메시지로 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }
  @override
  void dispose() {
    print("CallStartScreen dispose 실행됨");
    _controller.dispose();
    _callSession.disposeCall();
    _scrollController.dispose();
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ValueListenableBuilder<MediaStream?>(
                valueListenable: _callSession.remoteStreamNotifier,
                builder: (context, stream, _) {
                  final rtc = _callSession.rtcService;

                  if (!rtc.initialized) {
                    return const Center(child: Text('영상 초기화 중입니다...'));
                  }

                  return AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16), // ← 여기가 라운딩 정도
                      child: Container(
                        width: double.infinity,
                        color: Colors.black12,
                        child: RTCVideoView(
                          rtc.remoteRenderer,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 🔴 전화 끊기 버튼
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      fixedSize: const Size(171, 46),
                      // 너비와 높이 설정 (원하는 대로 조정 가능)
                      padding: EdgeInsets.zero, // 아이콘이 가운데 오도록 패딩 제거
                    ),
                    child: const Icon(Icons.call_end,
                        color: Colors.white, size: 36),
                  ),
                ],
              ),
            ),

            // 💬 채팅 메시지 리스트 (스크롤 되는 부분)
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '$todayDate\n아이가 입장하였습니다',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 12,
                          ),
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
              child: SizedBox(
                height: 45,
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        minimumSize: const Size(70, 48),
                      ),
                      onPressed: _onSendPressed,
                      child: const Text('전송'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
