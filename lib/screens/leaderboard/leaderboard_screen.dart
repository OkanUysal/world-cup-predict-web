import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/async_value_widget.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leaderboard_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final currentUserId = ref.watch(authProvider).user?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Sıralama')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(leaderboardProvider.future),
        child: AsyncValueWidget(
          value: leaderboardAsync,
          onRetry: () => ref.invalidate(leaderboardProvider),
          data: (scores) {
            if (scores.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.leaderboard_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz sıralama verisi yok',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: scores.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final score = scores[index];
                final rank = index + 1;
                final isMe = score.userId == currentUserId;

                return Card(
                  color: isMe ? Colors.green.shade50 : null,
                  child: ListTile(
                    leading: _RankBadge(rank: rank, isMe: isMe),
                    title: Text(
                      score.userName,
                      style: TextStyle(
                        fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: isMe ? const Text('Sen') : null,
                    trailing: Text(
                      '${score.totalPoints} puan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isMe
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, required this.isMe});

  final int rank;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final color = switch (rank) {
      1 => Colors.amber,
      2 => Colors.grey.shade400,
      3 => Colors.brown.shade300,
      _ => isMe
          ? Theme.of(context).colorScheme.primary
          : Colors.grey.shade300,
    };

    return CircleAvatar(
      backgroundColor: color,
      child: Text(
        '$rank',
        style: TextStyle(
          color: rank <= 3 || isMe ? Colors.white : Colors.grey.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
