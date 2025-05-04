import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class CallRecordingService {
  final _recorder = AudioRecorder();
  String? _currentFilePath;

  Future<void> startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception('🎙️ Microphone permission denied');
    }

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/conversation_${DateTime.now().millisecondsSinceEpoch}.wav';
    _currentFilePath = filePath;

    final config = RecordConfig(
      encoder: AudioEncoder.wav,
      bitRate: 128000,
      sampleRate: 44100,
    );

    await _recorder.start(
      config,
      path: filePath,
    );
  }

  Future<String?> stopRecording() async {
    if (await _recorder.isRecording()) {
      await _recorder.stop();
      return _currentFilePath;
    }
    return null;
  }

  Future<bool> isRecording() async => await _recorder.isRecording();
}