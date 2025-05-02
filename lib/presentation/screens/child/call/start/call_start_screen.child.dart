import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

import '../../../../../logic/providers/communication/call_session_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../../../../../core/constants/api/tts_api.dart';
import '../../../../../logic/providers/network/dio_provider.dart';

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

  Future<void> configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth |
      AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
    ));
  }

  Future<void> _speak(BuildContext context, String text, String characterId) async {
    final dio = context.read<DioProvider>().dio;
    await configureAudioSession();
    final player = AudioPlayer();

    try {
      final response = await dio.post(
        TtsAPI.requestTTS,
        data: {'text': text, 'characterId': characterId},
        options: Options(responseType: ResponseType.bytes),
      );

      final audioBytes = response.data;
      await player.setAudioSource(ByteStreamSource(audioBytes));

      // final tempDir = await getTemporaryDirectory();
      // final file = File('${tempDir.path}/tts.wav');
      // await file.writeAsBytes(audioBytes);
      // await player.setFilePath('${tempDir.path}/tts.wav');
      await player.setVolume(1.0);
      await player.play();

    player.dispose();
    } catch (e) {
      print('❌ TTS 요청 실패: $e');
    }
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
                      _speak(context, latest, "char001");
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