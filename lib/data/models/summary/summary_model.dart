class CounselingSummary {
  final String title;
  final String content;
  final int duration;
  final DateTime startAt;

  CounselingSummary({
    required this.title,
    required this.content,
    required this.duration,
    required this.startAt,
  });

  factory CounselingSummary.fromJson(Map<String, dynamic> json) {
    return CounselingSummary(
      title: json['title'],
      content: json['content'],
      duration: json['duration'],
      startAt: DateTime.parse(json['startAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'duration': duration,
      'startAt': startAt.toIso8601String(),
    };
  }
}