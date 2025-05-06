class FriendRequest {
  final int requestId;
  final int userId;
  final String userName;

  FriendRequest({
    required this.requestId,
    required this.userId,
    required this.userName,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      requestId: json['requestId'],
      userId: json['userId'],
      userName: json['userName'],
    );
  }
}