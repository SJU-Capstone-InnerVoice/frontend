import 'package:flutter/material.dart';
import 'package:inner_voice/core/constants/api/tts_api.dart';
import 'package:inner_voice/logic/providers/character/character_img_provider.dart';
import 'package:inner_voice/logic/providers/communication/call_request_provider.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../logic/providers/communication/call_session_provider.dart';
import '../../../../../logic/providers/network/dio_provider.dart';
import '../../../../../logic/providers/record/call_record_provider.dart';
import '../../../../../data/models/record/tts_segment_model.dart';
import '../../../../../data/models/character/character_image_model.dart';
import 'package:lottie/lottie.dart';

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

class CallStartScreen extends StatefulWidget  {
  const CallStartScreen({super.key});

  @override
  State<CallStartScreen> createState() => _CallStartScreenState();
}

class _CallStartScreenState extends State<CallStartScreen> with TickerProviderStateMixin{
  late final CallSessionProvider _callSession;
  late final CallRecordProvider _recordProvider;
  late final CallRequestProvider _callRequest;
  late final CharacterImgProvider _characterImgProvider;
  late final Future<void> _initFuture;

  late final _characters;
  late final _imageUrl;
  String? _lastSpoken;

  late final AnimationController _lottieController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;


  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.voiceChat,
    ));
    await session.setActive(true);
  }

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(vsync: this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true); // 계속 반복 (커졌다 작아졌다)

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _callRequest = context.read<CallRequestProvider>();
    _recordProvider = context.read<CallRecordProvider>();
    _characterImgProvider = context.read<CharacterImgProvider>();
    _callRequest.stopPolling();

    _initFuture = _initializeAll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _callSession = context.watch<CallSessionProvider>();
  }

  @override
  void dispose() {
    print("📴 CallStartScreen dispose 실행됨");
    _lastSpoken = null;
    _callSession.disposeCall();
    _callSession.clearMessages();
    _callRequest.stopPolling();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CallSessionProvider>().clearMessages();
      }
    });
    _lottieController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _speak(
      BuildContext context, String text, String characterId) async {
    final dio = context.read<DioProvider>().dio;

    final player = AudioPlayer(handleAudioSessionActivation: false);

    try {
      final response = await dio.post(
        TtsAPI.requestTTS,
        data: {'text': text, 'characterId': characterId},
        options: Options(responseType: ResponseType.bytes),
      );

      /// real TTS Server
      // final formData = FormData.fromMap({
      //   'user_id': 'colab_user',
      //   'weight_name': 'new_dora',
      //   'text': text,
      // });
      //
      // final response = await dio.post(
      //   "https://7b3c-211-180-114-56.ngrok-free.app/synthesize",
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

      _lottieController.repeat();
      await player.play();
      _lottieController.stop();


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

  Future<void> _initializeAll() async {
    final parentId = _callRequest.parentId.toString();
    await _characterImgProvider.loadImagesFromServer(parentId);
    await _recordProvider.startRecording();
    await _configureAudioSession();
    print('🎙️ 녹음 시작됨');
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
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final parentId = _callRequest.parentId.toString();
        final characterId = _callRequest.characterId.toString();
        final characters = _characterImgProvider.getCharacters(parentId);
        final characterImage = characters.firstWhere(
          (c) => c.id == characterId,
          orElse: () =>
              CharacterImage(id: '', name: '', imageUrl: '', type: ''),
        );

        final imageUrl = characterImage.imageUrl;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Stack(
              children: [
                Consumer<CallSessionProvider>(
                  builder: (context, session, _) {
                    final messages = session.messages;
                    if (messages.isNotEmpty) {
                      final latest = messages.last;

                      _lastSpoken = latest;
                      Future.microtask(() {
                        _speak(context, _lastSpoken!, characterId);
                      });
                    }
                    return const SizedBox.shrink();
                  },
                ),
                Column(
                  children: [
                    const Spacer(),
                    Center(
                      child: Container(
                        width: 330,
                        height: 330,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black12,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                frameBuilder: (context, child, frame,
                                    wasSynchronouslyLoaded) {
                                  if (frame == null) {
                                    return Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        width: 330,
                                        height: 330,
                                        color: Colors.white,
                                      ),
                                    );
                                  }
                                  return child;
                                },
                              )
                            : const Icon(Icons.image_not_supported),
                      ),
                    ),
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Lottie.asset(
                        'assets/animations/speak.json',
                        controller: _lottieController,
                        width: 100,
                        height: 100,
                        onLoaded: (composition) {
                          _lottieController.duration = composition.duration;
                        },
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: IconButton(
                        icon: const Icon(Icons.call_end, color: Colors.white),
                        iconSize: 48,
                        onPressed: () => context.go('/child/call/end'),
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
      },
    );
  }
}
