import 'package:flutter/material.dart';

import '../core/utils/date_utils.dart';
import '../models/event.dart';
import '../models/prediction.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final EventWithPrediction item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final event = item.event;
    final prediction = item.myPrediction;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatusBadge(status: event.status),
                  const Spacer(),
                  Text(
                    event.type.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                event.subtitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (event.type == EventType.matchScore) ...[
                const SizedBox(height: 4),
                Text(
                  event.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    'Son tarih: ${AppDateUtils.formatUtc(event.deadline)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              if (event.type == EventType.matchScore &&
                  event.metadata['kickoff_gmt'] != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.sports_soccer,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      'Maç: ${AppDateUtils.formatUtc(event.metadata['kickoff_gmt'] as String)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
              if (prediction != null) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(Icons.check_circle,
                        size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Tahminin: ${prediction.displayChoice}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (event.status == EventStatus.completed &&
                        prediction.pointsAwarded > 0) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+${prediction.pointsAwarded} puan',
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ] else if (event.status == EventStatus.open) ...[
                const SizedBox(height: 8),
                Text(
                  'Henüz tahmin girilmedi',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.orange.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final EventStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, bgColor) = switch (status) {
      EventStatus.open => (Colors.green.shade800, Colors.green.shade50),
      EventStatus.locked => (Colors.orange.shade800, Colors.orange.shade50),
      EventStatus.completed => (Colors.blue.shade800, Colors.blue.shade50),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String formatPredictionChoice(Prediction prediction) =>
    prediction.displayChoice;
