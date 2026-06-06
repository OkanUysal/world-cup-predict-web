class Prediction {
  const Prediction({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.choice,
    required this.pointsAwarded,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
  });

  final String id;
  final String eventId;
  final String userId;
  final Map<String, dynamic> choice;
  final int pointsAwarded;
  final String createdAt;
  final String updatedAt;
  final String? userName;

  factory Prediction.fromJson(Map<String, dynamic> json) {
    final choiceRaw = json['choice'];
    return Prediction(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      choice: choiceRaw is Map
          ? Map<String, dynamic>.from(choiceRaw)
          : const {},
      pointsAwarded: (json['points_awarded'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      userName: json['user_name'] as String?,
    );
  }

  String get displayChoice {
    if (choice.containsKey('home_score') && choice.containsKey('away_score')) {
      return '${choice['home_score']} - ${choice['away_score']}';
    }
    if (choice.containsKey('team')) {
      return choice['team'] as String;
    }
    return choice.toString();
  }
}
