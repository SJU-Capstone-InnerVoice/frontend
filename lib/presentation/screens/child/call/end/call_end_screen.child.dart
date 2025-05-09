import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inner_voice/logic/providers/communication/call_request_provider.dart';
import 'package:just_audio/just_audio.dart';
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

  final AudioPlayer _originalPlayer = AudioPlayer();
  Duration? _originalDuration;

  Future<void> _playOriginalFile() async {
    final record = _recordProvider.record;
    if (record == null || record.micRecordPath.isEmpty) {
      print('⚠️ 원본 녹음 파일이 없습니다.');
      return;
    }

    try {
      if (_originalPlayer.playing) {
        await _originalPlayer.stop();
        print('⏹️ 원본 재생 중단');
      }

      final duration = await _originalPlayer.setFilePath(record.micRecordPath);
      setState(() {
        _originalDuration = duration;
      });

      print('🎤 원본 재생 시간: ${duration?.inMilliseconds}ms');
      await _originalPlayer.play();
      print('▶️ 원본 재생 시작');
    } catch (e) {
      print('❌ 원본 재생 실패: $e');
    }
  }

  Future<void> _mergeRecording() async {
    final outputFileName = 'merged_${DateTime.now().millisecondsSinceEpoch}';
    final mergedPath = await context
        .read<CallRecordProvider>()
        .mergeRecordingsToSingleFile(outputFileName);

    setState(() {
      _mergedFilePath = mergedPath;
      _hasMerged = true;
    });
  }

  Future<void> _playMergedFile() async {
    if (_mergedFilePath == null) {
      print('⚠️ 재생할 파일이 없습니다.');
      return;
    }

    try {
      if (_player.playing) {
        await _player.stop();
        print('⏹️ 이전 재생 중단');
      }

      final duration = await _player.setFilePath(_mergedFilePath!);
      setState(() {
        _duration = duration;
      });
      print('🎧 파일 재생 시간: ${duration?.inMilliseconds}ms');

      await _player.play();
      print('▶️ 재생 시작');
    } catch (e) {
      print('❌ 재생 실패: $e');
    }
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
    if (!_callRequest.isPolling) {
      _callRequest.startPolling();
      debugPrint("🔁 CallEndScreen dispose에서 polling 재시작");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recordProvider = context.watch<CallRecordProvider>();
    final record = recordProvider.record;

    final canMerge = !_hasMerged &&
        !recordProvider.isRecording &&
        record != null &&
        record.micRecordPath.isNotEmpty &&
        record.ttsSegments.isNotEmpty;

    if (canMerge) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mergeRecording();
      });
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: canMerge ? _mergeRecording : null,
              icon: const Icon(Icons.merge_type),
              label: const Text('병합하기'),
            ),
            const SizedBox(height: 16),
            if (_mergedFilePath != null) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              const Text('병합 완료!'),
              const SizedBox(height: 8),
              Text(_mergedFilePath ?? '', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _playMergedFile,
                icon: const Icon(Icons.play_arrow),
                label: const Text('재생하기'),
              ),
              const SizedBox(height: 8),
              StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final total = _duration ?? Duration.zero;

                  return Column(
                    children: [
                      Slider(
                        min: 0,
                        max: total.inMilliseconds.toDouble(),
                        value: position.inMilliseconds
                            .clamp(0, total.inMilliseconds)
                            .toDouble(),
                        onChanged: (value) {
                          _player.seek(Duration(milliseconds: value.toInt()));
                        },
                      ),
                      Text(
                        '🔊 ${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')} / '
                        '${total.inMinutes}:${(total.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _playOriginalFile,
              icon: const Icon(Icons.record_voice_over),
              label: const Text('원본 녹음 재생'),
            ),
            if (_originalDuration != null) ...[
              Text(
                '🎙️ 원본 길이: ${_originalDuration!.inMinutes}:${(_originalDuration!.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              StreamBuilder<Duration>(
                stream: _originalPlayer.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final total = _originalDuration ?? Duration.zero;

                  return Column(
                    children: [
                      Slider(
                        min: 0,
                        max: total.inMilliseconds.toDouble(),
                        value: position.inMilliseconds
                            .clamp(0, total.inMilliseconds)
                            .toDouble(),
                        onChanged: (value) {
                          _originalPlayer
                              .seek(Duration(milliseconds: value.toInt()));
                        },
                      ),
                      Text(
                        '🔊 ${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')} / '
                        '${total.inMinutes}:${(total.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  );
                },
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.go("/child/call");
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text("뒤로가기"),
            ),
          ],
        ),
      ),
    );
  }
}
