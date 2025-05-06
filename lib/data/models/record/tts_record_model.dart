import 'tts_segment_model.dart';
import 'session_metadata_model.dart';

class TtsRecordModel {
  final String micRecordPath;              // 마이크 전체 녹음 파일 경로
  final List<TtsSegmentModel> ttsSegments;      // TTS 재생 정보들
  final SessionMetadataModel metadata;

  TtsRecordModel({
    required this.micRecordPath,
    required this.ttsSegments,
    required this.metadata,
  });

  factory TtsRecordModel.fromJson(Map<String, dynamic> json) => TtsRecordModel(
    micRecordPath: json['mic_record'],
    ttsSegments: (json['tts_segments'] as List)
        .map((e) => TtsSegmentModel.fromJson(e))
        .toList(),
    metadata: SessionMetadataModel.fromJson(json['metadata']),
  );

  Map<String, dynamic> toJson() => {
    'mic_record': micRecordPath,
    'tts_segments': ttsSegments.map((e) => e.toJson()).toList(),
    'metadata': metadata.toJson(),
  };
}