class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.role,
    this.channelId,
    this.totalPoints,
  });

  final String id;
  final String name;
  final String role;
  final String? channelId;
  final int? totalPoints;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      channelId: json['channel_id'] as String?,
      totalPoints: json['total_points'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        if (channelId != null) 'channel_id': channelId,
        if (totalPoints != null) 'total_points': totalPoints,
      };
}
