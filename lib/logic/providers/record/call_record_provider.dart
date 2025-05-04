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
    _isRecording = true;
    notifyListeners();
  }

  Future<void> stopRecording() async {
    final path = await _recordingService.stopRecording();
    if (path != null && _startedAt != null) {
      final duration = DateTime.now().difference(_startedAt!).inMilliseconds;
      _record = TtsRecordModel(
        micRecordPath: path,
        metadata: SessionMetadataModel(
          sessionId: 'dummy-session',
          startedAt: _startedAt!.toIso8601String(),
          durationMs: duration,
          userId: 'dummy-user',
          characterId: 'dummy-character',
        ),
        ttsSegments: [],
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

  void clear() {
    _record = null;
    _startedAt = null;
    _isRecording = false;
    notifyListeners();
  }
}