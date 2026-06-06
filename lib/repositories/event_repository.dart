import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../models/event.dart';
import '../models/prediction.dart';
import '../models/user_score.dart';

class EventRepository {
  EventRepository(this._client);

  final ApiClient _client;

  Future<List<EventWithPrediction>> getEvents({required String status}) async {
    return _client.get(
      '/events',
      queryParameters: {'status': status},
      parser: (data) => (data as List)
          .map(
            (e) => EventWithPrediction.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Future<EventDetailResponse> getEvent(String id) async {
    return _client.get(
      '/events/$id',
      parser: (data) =>
          EventDetailResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Prediction> submitPrediction({
    required String eventId,
    required Map<String, dynamic> choice,
  }) async {
    return _client.put(
      '/events/$eventId/prediction',
      data: {'choice': choice},
      parser: (data) => Prediction.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<Prediction>> getChannelPredictions(String eventId) async {
    return _client.get(
      '/events/$eventId/predictions',
      parser: (data) => (data as List)
          .map((e) => Prediction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class UserRepository {
  UserRepository(this._client);

  final ApiClient _client;

  Future<List<UserScore>> getLeaderboard() async {
    return _client.get(
      '/leaderboard',
      parser: (data) => (data as List)
          .map((e) => UserScore.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(ref.watch(apiClientProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(apiClientProvider));
});
