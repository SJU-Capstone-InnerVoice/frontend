import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'package:another_flushbar/flushbar.dart';

class RecordingBottomSheet extends StatefulWidget {
  const RecordingBottomSheet({super.key});

  @override
  State<RecordingBottomSheet> createState() => _RecordingBottomSheetState();
}

class _RecordingBottomSheetState extends State<RecordingBottomSheet> {
  bool isRecording = false;
  Duration duration = Duration.zero;
  Timer? _timer;

  void _startRecording() {
    // TODO: 실제 녹음 시작 로직
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => duration += const Duration(seconds: 1));
    });

    setState(() => isRecording = true);
  }

  void _stopRecording() {
    // TODO: 실제 녹음 종료 후 임시 저장
    _timer?.cancel();
    setState(() => isRecording = false);
  }

  void _cancelRecording() {
    setState(() {
      isRecording = false;
      duration = Duration.zero;
    });
    _timer?.cancel();
  }

  void _attachRecording() {
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
    ).show(context).then((_) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
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
                  animate: isRecording, // ✅ 녹음 중일 때만 움직이게
                ),
              ),
            ),

            // 중간 Spacer로 밀기
            const Spacer(),

            // 하단 타이머
            Text(
              '${duration.inMinutes.toString().padLeft(2, '0')}:${duration
                  .inSeconds.remainder(60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 16),

            // 버튼 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 20),
                IconButton(
                  onPressed: _cancelRecording,
                  icon: const Icon(Icons.delete_outline, size: 40),
                  tooltip: '삭제',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    shape: const CircleBorder(),
                  ),
                ),
                ElevatedButton(
                  onPressed: isRecording ? _stopRecording : _startRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRecording ? Colors.black : Colors.black,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(24),
                  ),
                  child: Icon(
                    isRecording ? Icons.stop : Icons.mic,
                    size: 32,
                  ),
                ),
                IconButton(
                  onPressed: _attachRecording,
                  icon: const Icon(Icons.upload_rounded, size: 40),
                  tooltip: '첨부',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
