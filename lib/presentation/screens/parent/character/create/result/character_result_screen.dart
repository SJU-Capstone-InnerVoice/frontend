import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:inner_voice/logic/providers/character/character_img_provider.dart';
import 'package:inner_voice/logic/providers/user/user_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../progress/widgets/audio_item_widget.dart';
import 'package:provider/provider.dart';

enum VoiceResultState { loading, waitingApi, requestingApi, done }

VoiceResultState _state = VoiceResultState.loading;

class VoiceResultScreen extends StatefulWidget {
  const VoiceResultScreen({super.key});

  @override
  State<VoiceResultScreen> createState() => _VoiceResultScreenState();
}

class _VoiceResultScreenState extends State<VoiceResultScreen>
    with TickerProviderStateMixin {
  VoiceResultState _state = VoiceResultState.loading;
  File? mergedFile;
  late final AudioPlayer _player;
  Duration? _duration;
  bool _isPrepared = false;
  late String _charachterName;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isPrepared) {
      _isPrepared = true;
      _prepare();
    }
  }

  Future<void> _prepare() async {
    _fadeController.reset();
    _fadeController.forward();

    /// 음성 합성 화면
    await Future.delayed(const Duration(seconds: 2));

    final filePaths = GoRouterState.of(context).extra as List<String>;
    final files = filePaths.map((path) => File(path)).toList();
    await Future.delayed(const Duration(seconds: 1));
    final userId = context.read<UserProvider>().user?.userId ?? "-1";
    final characterName =
        context.read<CharacterImgProvider>().getCharacters(userId).last.name;
    _charachterName = characterName;
    final characterId =
        context.read<CharacterImgProvider>().getCharacters(userId).last.id;

    final merged = await _mergeAudioFilesAndClean(
      fileNameWithoutExt: characterName,
      files: files,
    );
    await _player.setFilePath(merged.path);
    final dur = await _player.durationStream.firstWhere((d) => d != null);
    setState(() {
      mergedFile = merged;
      _duration = dur;
      _state = VoiceResultState.waitingApi;
    });

    /// AI 분석(음성 합성) 중 화면
    _fadeController.reset();
    _fadeController.forward();
    await Future.delayed(const Duration(seconds: 4));
    setState(() => _state = VoiceResultState.requestingApi);

    _fadeController.reset();
    _fadeController.forward();

    /// 음성 요약 결과 가져오는 화면
    await _sendApiRequest();
    setState(() => _state = VoiceResultState.done);
    _fadeController.reset();
    _fadeController.forward();

    /// 마지막 화면
  }

  Future<void> _sendApiRequest() async {
    print('🌐 API 요청 시작...');
    await Future.delayed(const Duration(seconds: 4));
    print('✅ API 요청 완료!');
  }

  Future<File> _mergeAudioFilesAndClean({
    required String fileNameWithoutExt,
    required List<File> files,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final output = File('${tempDir.path}/$fileNameWithoutExt.m4a');

    final inputs = files.map((f) => "-i ${f.path}").join(' ');
    final command =
        "$inputs -filter_complex concat=n=${files.length}:v=0:a=1 -y ${output.path}";

    await FFmpegKit.execute(command);

    final allFiles = tempDir.listSync();
    for (var f in tempDir.listSync()) {
      if (f is File &&
          f.path != output.path &&
          (f.path.endsWith('.m4a') ||
              f.path.endsWith('.wav') ||
              f.path.endsWith('.mp3'))) {
        print('🧹 Deleting audio file: ${f.path}');
        try {
          await f.delete();
        } catch (_) {}
      }
    }

    return output;
  }

  @override
  void dispose() {
    _player.dispose();
    _fadeController.dispose();
    _scaleController.dispose();

    super.dispose();
  }

  String formatDuration(Duration? duration) {
    if (duration == null) return "--:--";
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return NumberFormat('00').format(minutes) +
        ":" +
        NumberFormat('00').format(seconds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _buildContentByState(),
              ),
            ),
            if (mergedFile != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: AudioItemWidget(
                  file: mergedFile!,
                  player: _player,
                  duration: _duration,
                ),
              ),
            const SizedBox(height: 60),
          ],
        ),
      ),
      bottomSheet: _state == VoiceResultState.done
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home, size: 32),
                    tooltip: '홈으로',
                    onPressed: () {
                      context.go('/parent/call/');
                    },
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildContentByState() {
    Widget child;

    switch (_state) {
      case VoiceResultState.loading:
        child = Column(
          key: const ValueKey('loading'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange,
                      blurRadius: 100,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(
                  strokeWidth: 1,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
            ),
            const SizedBox(height: 80),
            const Text(
              '목소리를 합지고 있어요!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '잠시만 기다려 주세요..!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        );
        break;

      case VoiceResultState.waitingApi:
        child = Column(
          key: const ValueKey('waiting'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              padding: const EdgeInsets.all(20),
              child: Lottie.asset(
                'assets/animations/loading_elephant.json',
                repeat: true,
              ),
            ),
            const SizedBox(height: 50),
            const Text(
              'AI가 준비 중이에요!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '잠시만 기다려 주세요...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        );
        break;

      case VoiceResultState.requestingApi:
        child = Column(
          key: const ValueKey('requesting'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Lottie.asset(
                'assets/animations/work_bear.json',
                repeat: true,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'AI가 분석 중입니다!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '유사한 목소리를 배우고 있어요...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        );
        break;

      case VoiceResultState.done:
        child = Column(
          key: const ValueKey('done'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              child: Lottie.asset('assets/animations/pigeon.json'),
            ),
            const SizedBox(height: 50),
            const Text(
              '완료되었습니다!',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            ),
            const SizedBox(height: 8),
            Text(
              '${_charachterName}로 아이와 대화해볼까요?!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        );
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeInOut,
      child: child,
    );
  }
}
