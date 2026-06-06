import '../models/prediction.dart';

enum EventType {
  matchScore('match_score'),
  champion('champion'),
  runnerUp('runner_up'),
  thirdPlace('third_place');

  const EventType(this.value);
  final String value;

  static EventType fromString(String value) {
    return EventType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EventType.matchScore,
    );
  }

  String get label {
    switch (this) {
      case EventType.matchScore:
        return 'Maç Skoru';
      case EventType.champion:
        return 'Şampiyon';
      case EventType.runnerUp:
        return 'İkinci';
      case EventType.thirdPlace:
        return 'Üçüncü';
    }
  }
}

enum EventStatus {
  open('open'),
  locked('locked'),
  completed('completed');

  const EventStatus(this.value);
  final String value;

  static EventStatus fromString(String value) {
    return EventStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EventStatus.open,
    );
  }

  String get label {
    switch (this) {
      case EventStatus.open:
        return 'Açık';
      case EventStatus.locked:
        return 'Kilitli';
      case EventStatus.completed:
        return 'Tamamlandı';
    }
  }
}

class Event {
  const Event({
    required this.id,
    required this.type,
    required this.title,
    required this.metadata,
    required this.deadline,
    required this.status,
    required this.createdAt,
    this.result,
  });

  final String id;
  final EventType type;
  final String title;
  final Map<String, dynamic> metadata;
  final String deadline;
  final EventStatus status;
  final Map<String, dynamic>? result;
  final String createdAt;

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      type: EventType.fromString(json['type'] as String),
      title: json['title'] as String,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      deadline: json['deadline'] as String,
      status: EventStatus.fromString(json['status'] as String),
      result: json['result'] != null
          ? Map<String, dynamic>.from(json['result'] as Map)
          : null,
      createdAt: json['created_at'] as String,
    );
  }

  String get subtitle {
    if (type == EventType.matchScore) {
      final home = metadata['home_team'] ?? '';
      final away = metadata['away_team'] ?? '';
      return '$home vs $away';
    }
    return type.label;
  }

  List<String> get teams {
    final teamsList = metadata['teams'];
    if (teamsList is List) {
      return teamsList.map((e) => e.toString()).toList();
    }
    return [];
  }

  String? get resultDisplay {
    if (result == null) return null;
    if (result!.containsKey('home_score') && result!.containsKey('away_score')) {
      return '${result!['home_score']} - ${result!['away_score']}';
    }
    if (result!.containsKey('team')) {
      return result!['team'] as String?;
    }
    return result.toString();
  }
}

class EventWithPrediction {
  const EventWithPrediction({
    required this.event,
    this.myPrediction,
  });

  final Event event;
  final Prediction? myPrediction;

  factory EventWithPrediction.fromJson(Map<String, dynamic> json) {
    return EventWithPrediction(
      event: Event.fromJson(json['event'] as Map<String, dynamic>),
      myPrediction: json['my_prediction'] != null
          ? Prediction.fromJson(
              json['my_prediction'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class EventDetailResponse {
  const EventDetailResponse({
    required this.event,
    this.myPrediction,
  });

  final Event event;
  final Prediction? myPrediction;

  factory EventDetailResponse.fromJson(Map<String, dynamic> json) {
    return EventDetailResponse(
      event: Event.fromJson(json['event'] as Map<String, dynamic>),
      myPrediction: json['my_prediction'] != null
          ? Prediction.fromJson(
              json['my_prediction'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}
