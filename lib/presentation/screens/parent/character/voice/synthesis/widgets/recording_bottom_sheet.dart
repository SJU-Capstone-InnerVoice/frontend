import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'package:another_flushbar/flushbar.dart';
import 'dart:io';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class RecordingBottomSheet extends StatefulWidget {
  const RecordingBottomSheet({super.key, required this.onRecordingComplete});

  final void Function(File file, Duration duration) onRecordingComplete;

  @override
  State<RecordingBottomSheet> createState() => _RecordingBottomSheetState();
}

class _RecordingBottomSheetState extends State<RecordingBottomSheet> {
  bool _isRecording = false;
  Duration _duration = Duration.zero;
  Timer? _timer;
  final _recorder = AudioRecorder();
  String? _recordedPath;

  void _toggleRecording() async {
    if (!_isRecording) {
      final dir = await getTemporaryDirectory();
      _recordedPath =
          '${dir.path}/recorded_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _recordedPath!,
      );
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _duration += const Duration(seconds: 1));
      });
      setState(() => _isRecording = true);
    } else {
      final path = await _recorder.stop();
      if (_timer != null && _timer!.isActive) {
        _timer!.cancel();
      }
      setState(() => _isRecording = false);

      if (path != null) {
        final file = File(path);
        final player = AudioPlayer();
        await player.setFilePath(file.path);
        final d = await player.duration ?? _duration;
        player.dispose();
        setState(() => _duration = Duration.zero);

        widget.onRecordingComplete(file, d);

        Flushbar(
          message: "녹음이 업로드되었습니다.",
          flushbarPosition: FlushbarPosition.TOP,
          flushbarStyle: FlushbarStyle.FLOATING,
          duration: const Duration(milliseconds: 1000),
          animationDuration: const Duration(milliseconds: 1),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          borderRadius: BorderRadius.circular(12),
          backgroundColor: Colors.black.withAlpha(200),
          icon: const Icon(Icons.check, color: Colors.white),
        ).show(context);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 상단: 중앙에 떠 있는 파형
            Align(
              alignment: Alignment.topCenter,
              child: Center(
                child: Lottie.asset(
                  'assets/animations/wave_form.json',
                  height: 20,
                  width: 200,
                  fit: BoxFit.fitWidth,
                  repeat: true,
                  animate: _isRecording,
                ),
              ),
            ),

            // 중간 Spacer로 밀기
            const Spacer(),

            // 하단 타이머
            Text(
              '${_duration.inMinutes.toString().padLeft(2, '0')}:${_duration.inSeconds.remainder(60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 16),

            // 버튼 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _toggleRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.black : Colors.black,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(24),
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    size: 32,
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
