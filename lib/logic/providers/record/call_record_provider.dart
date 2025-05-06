import 'package:flutter/material.dart';
import '../../../data/models/record/tts_record_model.dart';
import '../../../data/models/record/session_metadata_model.dart';
import '../../../data/models/record/tts_segment_model.dart';
import '../../../services/call_recording_service.dart';

class CallRecordProvider extends ChangeNotifier {
  final CallRecordingService _recordingService = CallRecordingService();

  TtsRecordModel? _record;
  DateTime? _startedAt;

  TtsRecordModel? get record => _record;
  bool _isRecording = false;
  bool get isRecording => _isRecording;

  Future<void> startRecording() async {
    _startedAt = DateTime.now();
    await _recordingService.startRecording();

    _record = TtsRecordModel(
      micRecordPath: '',
      metadata: SessionMetadataModel(
        sessionId: 'dummy-session',
        startedAt: _startedAt!.toIso8601String(),
        durationMs: 0, // 나중에 갱신
        userId: 'dummy-user',
        characterId: 'dummy-character',
      ),
      ttsSegments: [],
    );

    _isRecording = true;
    notifyListeners();
  }

  Future<void> stopRecording() async {
    final path = await _recordingService.stopRecording();
    if (path != null && _startedAt != null && _record != null) {
      _record = TtsRecordModel(
        micRecordPath: path,
        metadata: SessionMetadataModel(
          sessionId: _record!.metadata.sessionId,
          startedAt: _record!.metadata.startedAt,
          durationMs: DateTime.now().difference(_startedAt!).inMilliseconds,
          userId: _record!.metadata.userId,
          characterId: _record!.metadata.characterId,
        ),
        ttsSegments: _record!.ttsSegments,
      );
    }
    _isRecording = false;
    notifyListeners();
  }

  void addTtsSegment(TtsSegmentModel segment) {
    if (_record == null) {
      print('⚠️ TtsRecordModel이 아직 초기화되지 않았습니다.');
      return;
    }
    _record?.ttsSegments.add(segment);
    notifyListeners();
  }

  Future<String?> mergeRecordingsToSingleFile(String outputFileName) async {
    if (_record == null) {
      print('⚠️ 병합할 기록이 없습니다.');
      return null;
    }

    final micPath = _record!.micRecordPath;
    final ttsPaths = _record!.ttsSegments.map((e) => e.audioPath).toList();

    final mergedPath = await _recordingService.mergeAudioFiles(
      micPath: micPath,
      ttsSegments: _record!.ttsSegments,
      outputFileName: outputFileName,
      durationMs: _record!.metadata.durationMs,
    );

    if (mergedPath != null) {
      print('📦 병합 결과 파일 경로: $mergedPath');
    }
    return mergedPath;
  }

  void clear() {
    _record = null;
    _startedAt = null;
    _isRecording = false;
    notifyListeners();
  }
}