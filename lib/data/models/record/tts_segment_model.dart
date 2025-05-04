class TtsSegmentModel {
  final String text;
  final String audioPath;
  final int startMs; // 마이크 기준 실행 지점만 있으면 충분

  TtsSegmentModel({
    required this.text,
    required this.audioPath,
    required this.startMs,
  });

  factory TtsSegmentModel.fromJson(Map<String, dynamic> json) => TtsSegmentModel(
    text: json['text'],
    audioPath: json['audio'],
    startMs: json['start'],
  );

  Map<String, dynamic> toJson() => {
    'text': text,
    'audio': audioPath,
    'start': startMs,
  };
}