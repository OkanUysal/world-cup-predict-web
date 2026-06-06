import 'package:flutter/material.dart';

import '../models/prediction.dart';
import 'event_card.dart';

class ChannelPredictionsList extends StatelessWidget {
  const ChannelPredictionsList({
    super.key,
    required this.predictions,
    this.highlightUserId,
  });

  final List<Prediction> predictions;
  final String? highlightUserId;

  @override
  Widget build(BuildContext context) {
    if (predictions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Henüz tahmin yok.'),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: predictions.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final prediction = predictions[index];
        final isMe = prediction.userId == highlightUserId;

        return ListTile(
          tileColor: isMe ? Colors.green.shade50 : null,
          leading: CircleAvatar(
            backgroundColor: isMe
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            child: Text(
              (prediction.userName ?? '?')[0].toUpperCase(),
              style: TextStyle(
                color: isMe ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            prediction.userName ?? 'Anonim',
            style: TextStyle(
              fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(formatPredictionChoice(prediction)),
          trailing: prediction.pointsAwarded > 0
              ? Chip(
                  label: Text('+${prediction.pointsAwarded}'),
                  backgroundColor: Colors.amber.shade100,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                )
              : null,
        );
      },
    );
  }
}
