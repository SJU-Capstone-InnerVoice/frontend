class SessionMetadataModel {
  final String sessionId;
  final String startedAt;     // ISO 형식: 2024-05-03T22:00:00+09:00
  final int durationMs;
  final String userId;
  final String characterId;

  SessionMetadataModel({
    required this.sessionId,
    required this.startedAt,
    required this.durationMs,
    required this.userId,
    required this.characterId,
  });

  factory SessionMetadataModel.fromJson(Map<String, dynamic> json) => SessionMetadataModel(
    sessionId: json['session_id'],
    startedAt: json['started_at'],
    durationMs: json['duration_ms'],
    userId: json['user_id'],
    characterId: json['character_id'],
  );

  Map<String, dynamic> toJson() => {
    'session_id': sessionId,
    'started_at': startedAt,
    'duration_ms': durationMs,
    'user_id': userId,
    'character_id': characterId,
  };
}