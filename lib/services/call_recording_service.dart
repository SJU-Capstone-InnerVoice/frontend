import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';

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

  Future<String?> mergeAudioFiles({
    required String micPath,
    required List<String> ttsPaths,
    required String outputFileName,
  }) async {
    final outputDir = (await getApplicationDocumentsDirectory()).path;
    final outputPath = '$outputDir/$outputFileName.wav';
    final listPath = '$outputDir/concat_list.txt';

    // 텍스트 파일 생성
    final buffer = StringBuffer();
    buffer.writeln("file '$micPath'");
    for (final path in ttsPaths) {
      buffer.writeln("file '$path'");
    }
    await File(listPath).writeAsString(buffer.toString());

    // ffmpeg 실행
    final session = await FFmpegKit.execute(
      "-f concat -safe 0 -i $listPath -c copy $outputPath",
    );

    final returnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      print("✅ 병합 완료: $outputPath");
      return outputPath;
    } else {
      print("❌ 병합 실패: ${returnCode?.getValue()}");
      return null;
    }
  }


  Future<void> deleteAudioResources({
    required String micPath,
    required List<String> ttsPaths,
  }) async {
    try {
      // 🎤 마이크 녹음 파일 삭제
      final micFile = File(micPath);
      if (await micFile.exists()) {
        await micFile.delete();
        print('🗑️ 마이크 파일 삭제됨: $micPath');
      }

      // 🧠 TTS 파일들 삭제
      for (final path in ttsPaths) {
        final ttsFile = File(path);
        if (await ttsFile.exists()) {
          await ttsFile.delete();
          print('🗑️ TTS 파일 삭제됨: $path');
        }
      }
    } catch (e) {
      print('❌ 오디오 파일 삭제 중 오류: $e');
    }
  }
}