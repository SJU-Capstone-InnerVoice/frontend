import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../synthesis/widgets/audio_item_widget.dart';

class VoiceResultScreen extends StatefulWidget {
  const VoiceResultScreen({super.key});

  @override
  State<VoiceResultScreen> createState() => _VoiceResultScreenState();
}

class _VoiceResultScreenState extends State<VoiceResultScreen> {
  File? mergedFile;
  late final AudioPlayer _player;
  Duration? _duration;
  bool _isPrepared = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
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

    final merged = await _mergeAudioFilesAndClean(files);
    await _player.setFilePath(merged.path);
    final dur = await _player.durationStream.firstWhere((d) => d != null);

    setState(() {
      mergedFile = merged;
      _duration = dur;
    });
  }

  Future<File> _mergeAudioFilesAndClean(List<File> files) async {
    final tempDir = await getTemporaryDirectory();
    final output = File('${tempDir.path}/merged_audio.m4a');

    final inputs = files.map((f) => "-i ${f.path}").join(' ');
    final command =
        "$inputs -filter_complex concat=n=${files.length}:v=0:a=1 -y ${output.path}";

    await FFmpegKit.execute(command);

    final allFiles = tempDir.listSync();
    for (var f in allFiles) {
      if (f is File && f.path != output.path) {
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
      appBar: AppBar(
        title: const Text('음성 합성 결과'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: mergedFile == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: AudioItemWidget(
                  file: mergedFile!,
                  player: _player,
                  duration: _duration,
                ),
              ),
      ),
    );
  }
}
