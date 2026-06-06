import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';
import '../repositories/event_repository.dart';

final leaderboardProvider = FutureProvider((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getLeaderboard();
});

final profileProvider = FutureProvider<UserProfile>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.getMe();
});
