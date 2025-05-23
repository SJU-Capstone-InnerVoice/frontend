import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:collection/collection.dart';
import '../data/models/record/tts_segment_model.dart';
import '../core/utils/logs/audio_logger.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:http_parser/http_parser.dart';
import '../../../../../core/constants/api/summary_api.dart';

class CallRecordingService {
  final _recorder = AudioRecorder();
  String? _currentFilePath;

  Future<void> startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception('🎙️ Microphone permission denied');
    }

    final dir = await getApplicationDocumentsDirectory();
    final filePath =
        '${dir.path}/conversation_${DateTime.now().millisecondsSinceEpoch}.wav';
    _currentFilePath = filePath;

    final config = RecordConfig(
      encoder: AudioEncoder.wav,
      bitRate: 128000,
      sampleRate: 44100,
      numChannels: 1,
      echoCancel: true,
    );

    await _recorder.start(
      config,
      path: filePath,
    );
  }

  Future<String?> stopRecording() async {
    if (await _recorder.isRecording()) {
      await _recorder.stop();
      await AudioLogger.printWavInfo(_currentFilePath!);

      return _currentFilePath;
    }
    return null;
  }

  Future<bool> isRecording() async => await _recorder.isRecording();

  Future<String?> mergeAudioFiles({
    required String micPath,
    required List<TtsSegmentModel> ttsSegments,
    required String outputFileName,
    required int durationMs,
  }) async {
    final outputDir = (await getApplicationDocumentsDirectory()).path;
    final outputPath = '$outputDir/$outputFileName.wav';
    if (ttsSegments.isEmpty) {
      print("⚠️ TTS 세그먼트 없음. 원본 파일만 복사");
      final originalFile = File(micPath);

      if (!await originalFile.exists()) {
        print('❌ 원본 파일이 존재하지 않습니다: $micPath');
        return null;
      }

      try {
        await originalFile.copy(outputPath);
        print('✅ 복사 완료: $outputPath');
        AudioLogger.printWavInfo(outputPath);

        await originalFile.delete();
        print('🗑️ 원본 파일 삭제됨: $micPath');
      } catch (e) {
        print('❌ 복사 중 예외 발생: $e');
        return null;
      }

      return outputPath;
    }


    AudioLogger.printWavInfo(micPath);
    // 입력 리스트 구성
    final inputs = <String>["-i '$micPath'"];
    for (final seg in ttsSegments) {
      inputs.add("-i '${seg.audioPath}'");
      AudioLogger.printWavInfo(seg.audioPath);
    }

    // ffmpeg 실행
    final durationSec = (durationMs / 1000).toStringAsFixed(2);
    final filterComplex = [
      "[0:0]atrim=duration=${durationSec}[mic]",
      ...ttsSegments.mapIndexed(
          (i, seg) => "[${i + 1}:0]adelay=${seg.startMs}|${seg.startMs}[td$i]"),
      "[mic]" +
          List.generate(ttsSegments.length, (i) => "[td$i]").join() +
          "amix=inputs=${ttsSegments.length + 1}:duration=first:dropout_transition=0[aout]"
    ].join("; ");

    final command = [
      ...inputs,
      "-t $durationSec",
      "-filter_complex \"$filterComplex\"",
      "-map \"[aout]\"",
      "-c:a pcm_s16le -ar 44100 -ac 1",
      "'$outputPath'"
    ].join(' ');

    print("🎛️ FFmpeg 명령어:\n$command");

    final session = await FFmpegKit.execute(command);

    final returnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      print("✅ 믹싱 완료: $outputPath");

      AudioLogger.printWavInfo(outputPath);

      await _deleteAllWavFilesExcept(outputPath);
      return outputPath;
    } else {
      print("❌ 믹싱 실패: ${returnCode?.getValue()}");
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
  Future<void> _deleteAllWavFilesExcept(String exceptPath) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = Directory(dir.path).listSync();

      for (var file in files) {
        if (file is File &&
            file.path.endsWith('.wav') &&
            file.path != exceptPath) {
          await file.delete();
          print('🗑️ 삭제됨: ${file.path}');
        }
      }
    } catch (e) {
      print('❌ 파일 삭제 중 오류 발생: $e');
    }
  }
}
