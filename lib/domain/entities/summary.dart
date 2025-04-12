// lib/domain/entities/summary.dart

class Summary {
  final String id; // summary 에 대한 ID
  final String userId; // user ID를 통해 접근
  final String content;
  final String title;
  final DateTime createAt;
  final Duration duration;

  Summary({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createAt,
    required this.duration,
  });
}