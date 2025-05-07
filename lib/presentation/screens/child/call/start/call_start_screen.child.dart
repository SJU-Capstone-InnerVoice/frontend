import 'package:flutter/material.dart';
import 'package:inner_voice/core/constants/api/tts_api.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import '../../../../../logic/providers/communication/call_session_provider.dart';
import '../../../../../logic/providers/network/dio_provider.dart';
import '../../../../../logic/providers/record/call_record_provider.dart';
import '../../../../../data/models/record/tts_segment_model.dart';

class ByteStreamSource extends StreamAudioSource {
  final List<int> data;

  ByteStreamSource(this.data);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= data.length;
    return StreamAudioResponse(
      sourceLength: data.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(data.sublist(start, end)),
      contentType: 'audio/wav', // 또는 audio/mpeg 등
    );
  }
}

class CallStartScreen extends StatefulWidget {
  const CallStartScreen({super.key});

  @override
  State<CallStartScreen> createState() => _CallStartScreenState();
}

class _CallStartScreenState extends State<CallStartScreen> {
  late final CallSessionProvider _callSession;
  late final CallRecordProvider _recordProvider;
  String? _lastSpoken;

  @override
  void initState() {
    super.initState();
    _recordProvider = context.read<CallRecordProvider>();

    Future.microtask(() async {
      try {
        await _recordProvider.startRecording();
        print('🎙️ 녹음 시작됨');
      } catch (e) {
        print('❌ 녹음 시작 실패: $e');
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _callSession = context.watch<CallSessionProvider>();
  }

  @override
  void dispose() {
    print("📴 CallStartScreen dispose 실행됨");
    _callSession.disposeCall();
    _callSession.clearMessages();
    super.dispose();
  }

  Future<void> _speak(
      BuildContext context, String text, String characterId) async {
    final dio = context.read<DioProvider>().dio;
    final player = AudioPlayer();
    try {
      final response = await dio.post(
        TtsAPI.requestTTS,
        data: {'text': text, 'characterId': characterId},
        options: Options(responseType: ResponseType.bytes),
      );

      /// real TTS Server
      // final formData = FormData.fromMap({
      //   'user_id': 'colab_user',
      //   'weight_name': 'ys',
      //   'text': text,
      // });
      //
      // final response = await dio.post(
      //   "https://82ae-211-180-114-56.ngrok-free.app/synthesize",
      //   data: formData,
      //   options: Options(
      //     responseType: ResponseType.bytes,
      //     contentType: 'multipart/form-data',
      //     sendTimeout: const Duration(seconds: 10),
      //     receiveTimeout: const Duration(seconds: 10),
      //     // connectTimeout은 Dio instance에서 설정
      //   ),
      // );

      final audioBytes = response.data;
      final filePath = await _saveTtsAudioFile(audioBytes);

      await player.setAudioSource(ByteStreamSource(audioBytes));
      await player.setVolume(1.0);
      // ⏱️ 현재 마이크 기준 경과 시간 측정
      final startedAt = _recordProvider.record?.metadata.startedAt;
      final startTime = DateTime.now();
      final startMs = startedAt == null
          ? 0
          : startTime.difference(DateTime.parse(startedAt)).inMilliseconds;

      await player.play();

      _recordProvider.addTtsSegment(
        TtsSegmentModel(
          text: text,
          audioPath: filePath,
          startMs: startMs,
        ),
      );
    } catch (e) {
      print('❌ TTS 요청 실패: $e');
    }
    player.dispose();
  }

  Future<String> _saveTtsAudioFile(List<int> audioBytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'tts_${DateTime.now().millisecondsSinceEpoch}.wav';
    final filePath = '${dir.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(audioBytes);

    print('💾 TTS 파일 저장됨: $filePath');
    return filePath;
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
                  _lastSpoken = latest;
                  print("리스트: $messages");
                  Future.microtask(() {
                    _speak(context, latest, "char001");
                  });
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
                    onPressed: () async {
                      await Future.delayed(Duration(seconds: 5));
                      context.go('/child/call/end');
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
