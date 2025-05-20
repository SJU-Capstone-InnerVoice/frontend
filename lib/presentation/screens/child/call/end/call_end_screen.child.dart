import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inner_voice/data/models/summary/summary_model.dart';
import 'package:inner_voice/logic/providers/communication/call_request_provider.dart';
import 'package:inner_voice/logic/providers/communication/call_session_provider.dart';
import 'package:inner_voice/logic/providers/summary/summary_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../../logic/providers/record/call_record_provider.dart';

class CallEndScreen extends StatefulWidget {
  const CallEndScreen({super.key});

  @override
  State<CallEndScreen> createState() => _CallEndScreenState();
}

class _CallEndScreenState extends State<CallEndScreen> {
  late final _recordProvider;
  String? _mergedFilePath;
  bool _hasMerged = false;
  final AudioPlayer _player = AudioPlayer();
  Duration? _duration;
  late final CallRequestProvider _callRequest;
  bool _isLoadingSummary = true;
  final AudioPlayer _originalPlayer = AudioPlayer();
  bool _isMerging = false;

  Future<void> _mergeRecording() async {
    print("▶️ 병합 시작");
    setState(() => _isLoadingSummary = true);

    final outputFileName = 'merged_${DateTime.now().millisecondsSinceEpoch}';
    final mergedPath = await context
        .read<CallRecordProvider>()
        .mergeRecordingsToSingleFile(outputFileName);
    print("✅ mergeRecordingsToSingleFile 완료: $mergedPath");

    Duration? duration;

    try {
      duration = await _player.setFilePath(mergedPath!);
      if (duration != null) {
        print("📏 병합된 파일 duration: ${duration.inMilliseconds}ms");
      } else {
        print("❌ duration이 null입니다.");
      }
    } catch (e) {
      print('❌ setFilePath 오류: $e');
      setState(() => _isLoadingSummary = false);
      return; // 실패 시 병합 종료
    }

    final record = context.read<CallRecordProvider>().record;
    final parentId = context.read<CallRequestProvider>().parentId;
    print("📋 Record 및 ParentId 확인 완료");

    if (record != null) {
      final startAt = DateTime.parse(record.metadata.startedAt);
      final durationMs = record.metadata.durationMs;

      print("🧠 Summary 생성 시작");
      await context.read<SummaryProvider>().createSummary(
            filePath: mergedPath,
            duration: durationMs,
            startAt: startAt,
          );
      print("🧠 Summary 생성 완료");

      final summary = context.read<SummaryProvider>().currentSummary;
      if (summary == null) {
        print("⚠️ Summary 생성 실패: currentSummary가 null입니다.");
      } else {
        try {
          await context
              .read<SummaryProvider>()
              .uploadSummaryToServer(summary, parentId!);
        } catch (e) {
          print("❌ 서버 업로드 실패: $e");
        }
        context.read<SummaryProvider>().printSummaries();
      }
    } else {
      print("⚠️ record가 null입니다.");
    }

    await Future.delayed(const Duration(seconds: 1));
    print("⏱️ 1초 대기 후 상태 업데이트 시도");

    setState(() {
      _mergedFilePath = mergedPath;
      _hasMerged = true;
      _duration = duration;
      _isLoadingSummary = false;
    });
    print("✅ setState 완료");
  }

  @override
  void initState() {
    super.initState();

    _callRequest = context.read<CallRequestProvider>();
    _recordProvider = context.read<CallRecordProvider>();
    (() async {
      try {
        await _recordProvider.stopRecording();

        final record = _recordProvider.record;
        if (record == null) {
          print('⚠️ 녹음 데이터가 없습니다.');
        } else {
          print('🎧 마이크 녹음 파일: ${record.micRecordPath}');
          print('🕒 시작 시각: ${record.metadata.startedAt}');
          print('⏱️ 통화 길이 (ms): ${record.metadata.durationMs}');
          print('🙍 사용자 ID: ${record.metadata.userId}');
          print('🧠 캐릭터 ID: ${record.metadata.characterId}');
          print('🆔 세션 ID: ${record.metadata.sessionId}');

          if (record.ttsSegments.isEmpty) {
            print('💬 저장된 TTS 세그먼트가 없습니다.');
          } else {
            print('💬 TTS 세그먼트 (${record.ttsSegments.length}개):');
            for (var i = 0; i < record.ttsSegments.length; i++) {
              final seg = record.ttsSegments[i];
              print('  [$i]');
              print('   • 문장: ${seg.text}');
              print('   • 파일: ${seg.audioPath}');
              print('   • 시작 시각 (ms): ${seg.startMs}');
            }
          }
        }
      } catch (e) {
        print('❌ 녹음 중지 실패: $e');
      }
    })();
  }

  @override
  void dispose() {
    _player.dispose();
    _originalPlayer.dispose();
    super.dispose();
  }

  Widget _buildResultContent(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0,horizontal: 20),
              child: Column(
                children: [
                  Text(
                    _duration == null
                        ? "0분 0초"
                        : "${_duration!.inMinutes}분 ${(_duration!.inSeconds % 60).toString().padLeft(2, '0')}초",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                          fontSize: 60,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "동안 대화해줘서 고마워!",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Lottie.asset(
                    'assets/animations/pigeon.json',
                    height: 180,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "헤헤! 오늘 너랑 전화해서 너무 신났어!\n다음에도 또 같이 놀자~!",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 300),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () {
                      context.go("/child/call");
                    },
                    child: Text(
                      "돌아갈래요!",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final recordProvider = context.watch<CallRecordProvider>();
    final record = recordProvider.record;

    final canMerge = !_hasMerged &&
        !_isMerging &&
        !recordProvider.isRecording &&
        record != null &&
        record.micRecordPath.isNotEmpty;

    if (canMerge) {
      _isMerging = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mergeRecording();
      });
    }

    if (!_callRequest.isPolling) {
      _callRequest.startPolling();
    }

    return Scaffold(
      body: SafeArea(
        child: _isLoadingSummary
            ? Center(
                child: Column(
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
                      'AI가 대화를 요약하고 있어요!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '오늘 하루를 기록해봐요!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : _buildResultContent(context),
      ),
    );
  }
}
