import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../synthesis/widgets/audio_item_widget.dart';
enum VoiceResultState { loading, waitingApi, requestingApi, done }
VoiceResultState _state = VoiceResultState.loading;

class VoiceResultScreen extends StatefulWidget {
  const VoiceResultScreen({super.key});

  @override
  State<VoiceResultScreen> createState() => _VoiceResultScreenState();
}

class _VoiceResultScreenState extends State<VoiceResultScreen> with SingleTickerProviderStateMixin{

  VoiceResultState _state = VoiceResultState.loading;
  File? mergedFile;
  late final AudioPlayer _player;
  Duration? _duration;
  bool _isPrepared = false;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
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
    final filePaths = GoRouterState.of(context).extra as List<String>;
    final files = filePaths.map((path) => File(path)).toList();
    await Future.delayed(const Duration(seconds: 1));

    final merged = await _mergeAudioFilesAndClean(files);
    await _player.setFilePath(merged.path);
    final dur = await _player.durationStream.firstWhere((d) => d != null);

    setState(() {
      mergedFile = merged;
      _duration = dur;
      _state = VoiceResultState.waitingApi;
    });
    _fadeController.forward();
    await Future.delayed(const Duration(seconds: 3));
    setState(() => _state = VoiceResultState.requestingApi);
    await _sendApiRequest();
    setState(() => _state = VoiceResultState.done);

  }

  Future<void> _sendApiRequest() async {
    print('🌐 API 요청 시작...');
    await Future.delayed(const Duration(seconds: 5));
    print('✅ API 요청 완료!');
  }

  Future<File> _mergeAudioFilesAndClean(List<File> files) async {
    final tempDir = await getTemporaryDirectory();
    final output = File('${tempDir.path}/merged_audio.m4a');

    final inputs = files.map((f) => "-i ${f.path}").join(' ');
    final command =
        "$inputs -filter_complex concat=n=${files.length}:v=0:a=1 -y ${output.path}";

    await FFmpegKit.execute(command);

    final allFiles = tempDir.listSync();
    for (var f in tempDir.listSync()) {
      if (f is File &&
          f.path != output.path &&
          (f.path.endsWith('.m4a') || f.path.endsWith('.wav') || f.path.endsWith('.mp3'))) {
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
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: AudioItemWidget(
                    file: mergedFile!,
                    player: _player,
                    duration: _duration,
                  ),
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
                context.go('/parent/character/add');
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
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              '병합 중입니다...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        );
        break;

      case VoiceResultState.waitingApi:
        child = Column(
          key: const ValueKey('waiting'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/animations/loading_elephant.json'),
            const SizedBox(height: 16),
            const Text(
              '잠시만 기다려 주세요...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        );
        break;

      case VoiceResultState.requestingApi:
        child = Column(
          key: const ValueKey('requesting'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/animations/work_bear.json'),
            const SizedBox(height: 16),
            const Text(
              'AI가 분석 중입니다...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        );
        break;

      case VoiceResultState.done:
        child = Column(
          key: const ValueKey('done'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/animations/pigeon.json'),
            const SizedBox(height: 16),
            const Text(
              '완료되었습니다!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green),
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
