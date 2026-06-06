import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event.dart';
import '../models/prediction.dart';
import '../repositories/event_repository.dart';

final eventsProvider =
    FutureProvider.family<List<EventWithPrediction>, String>((ref, status) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getEvents(status: status);
});

final eventDetailProvider =
    FutureProvider.family<EventDetailResponse, String>((ref, eventId) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getEvent(eventId);
});

final channelPredictionsProvider =
    FutureProvider.family<List<Prediction>, String>((ref, eventId) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getChannelPredictions(eventId);
});
