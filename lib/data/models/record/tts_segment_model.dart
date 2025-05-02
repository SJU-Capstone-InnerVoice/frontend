class TtsSegmentModel {
  final String text;         // TTS 문장
  final String audioPath;    // TTS 음성 파일 경로
  final int startMs;         // 시작 시간 (ms)
  final int endMs;           // 끝 시간 (ms)

  TtsSegmentModel({
    required this.text,
    required this.audioPath,
    required this.startMs,
    required this.endMs,
  });

  factory TtsSegmentModel.fromJson(Map<String, dynamic> json) => TtsSegmentModel(
    text: json['text'],
    audioPath: json['audio'],
    startMs: json['start'],
    endMs: json['end'],
  );

  Map<String, dynamic> toJson() => {
    'text': text,
    'audio': audioPath,
    'start': startMs,
    'end': endMs,
  };
}