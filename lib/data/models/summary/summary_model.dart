class Summary {
  final String title;
  final String content;
  final int duration;
  final DateTime startAt;

  Summary({
    required this.title,
    required this.content,
    required this.duration,
    required this.startAt,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
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