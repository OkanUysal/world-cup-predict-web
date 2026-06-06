class UserScore {
  const UserScore({
    required this.userId,
    required this.userName,
    required this.channelId,
    required this.totalPoints,
    required this.updatedAt,
  });

  final String userId;
  final String userName;
  final String channelId;
  final int totalPoints;
  final String updatedAt;

  factory UserScore.fromJson(Map<String, dynamic> json) {
    return UserScore(
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      channelId: json['channel_id'] as String,
      totalPoints: json['total_points'] as int? ?? 0,
      updatedAt: json['updated_at'] as String,
    );
  }
}
