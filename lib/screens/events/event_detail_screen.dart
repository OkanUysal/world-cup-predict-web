import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/error_message.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/async_value_widget.dart';
import '../../core/widgets/responsive_container.dart';
import '../../models/event.dart';
import '../../providers/auth_provider.dart';
import '../../providers/events_provider.dart';
import '../../repositories/event_repository.dart';
import '../../widgets/channel_predictions_list.dart';
import '../../widgets/match_score_input.dart';
import '../../widgets/team_picker.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  int _homeScore = 0;
  int _awayScore = 0;
  String? _selectedTeam;
  bool _isSubmitting = false;
  bool _initialized = false;

  void _initFromEvent(EventDetailResponse detail) {
    if (_initialized) return;
    final prediction = detail.myPrediction;
    if (prediction != null) {
      if (detail.event.type == EventType.matchScore) {
        _homeScore =
            (prediction.choice['home_score'] as num?)?.toInt() ?? 0;
        _awayScore =
            (prediction.choice['away_score'] as num?)?.toInt() ?? 0;
      } else {
        _selectedTeam = prediction.choice['team'] as String?;
      }
    }
    _initialized = true;
  }

  Future<void> _submitPrediction(Event event) async {
    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(eventRepositoryProvider);
      final Map<String, dynamic> choice;

      if (event.type == EventType.matchScore) {
        choice = {'home_score': _homeScore, 'away_score': _awayScore};
      } else {
        if (_selectedTeam == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lütfen bir takım seç')),
          );
          return;
        }
        choice = {'team': _selectedTeam};
      }

      await repo.submitPrediction(eventId: widget.eventId, choice: choice);
      ref.invalidate(eventDetailProvider(widget.eventId));
      ref.invalidate(eventsProvider('open'));
      ref.invalidate(eventsProvider('pending'));
      ref.invalidate(eventsProvider('completed'));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tahmin kaydedildi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyErrorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(eventDetailProvider(widget.eventId));
    final userId = ref.watch(authProvider).user?.id;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Event Detayı'),
      ),
      body: ResponsiveContainer(
        child: AsyncValueWidget(
          value: detailAsync,
          onRetry: () => ref.invalidate(eventDetailProvider(widget.eventId)),
          data: (detail) {
            _initFromEvent(detail);
            final event = detail.event;
            final canPredict = event.status == EventStatus.open;
            final showChannelPredictions =
                event.status != EventStatus.open;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.subtitle,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(event.title),
                          const SizedBox(height: 12),
                          _InfoRow(
                            icon: Icons.category,
                            label: 'Tip',
                            value: event.type.label,
                          ),
                          _InfoRow(
                            icon: Icons.schedule,
                            label: 'Son tarih',
                            value: AppDateUtils.formatUtc(event.deadline),
                          ),
                          if (event.type == EventType.matchScore) ...[
                            if (event.metadata['venue'] != null)
                              _InfoRow(
                                icon: Icons.stadium,
                                label: 'Stadyum',
                                value: event.metadata['venue'] as String,
                              ),
                            if (event.metadata['kickoff_gmt'] != null)
                              _InfoRow(
                                icon: Icons.sports_soccer,
                                label: 'Maç saati',
                                value: AppDateUtils.formatUtc(
                                  event.metadata['kickoff_gmt'] as String,
                                ),
                              ),
                          ],
                          if (event.resultDisplay != null)
                            _InfoRow(
                              icon: Icons.emoji_events,
                              label: 'Sonuç',
                              value: event.resultDisplay!,
                              highlight: true,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (detail.myPrediction != null)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                        title: const Text('Mevcut Tahminin'),
                        subtitle: Text(detail.myPrediction!.displayChoice),
                        trailing: detail.myPrediction!.pointsAwarded > 0
                            ? Text(
                                '+${detail.myPrediction!.pointsAwarded} puan',
                                style: TextStyle(
                                  color: Colors.amber.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                  if (canPredict) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Tahminini Gir',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (event.type == EventType.matchScore)
                      MatchScoreInput(
                        homeTeam: event.metadata['home_team'] as String? ?? 'Ev',
                        awayTeam: event.metadata['away_team'] as String? ?? 'Deplasman',
                        homeScore: _homeScore,
                        awayScore: _awayScore,
                        onHomeChanged: (v) => setState(() => _homeScore = v),
                        onAwayChanged: (v) => setState(() => _awayScore = v),
                      )
                    else
                      TeamPicker(
                        teams: event.teams,
                        selectedTeam: _selectedTeam,
                        onChanged: (v) => setState(() => _selectedTeam = v),
                        label: '${event.type.label} seç',
                      ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => _submitPrediction(event),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              detail.myPrediction != null
                                  ? 'Tahmini Güncelle'
                                  : 'Tahmini Kaydet',
                            ),
                    ),
                  ],
                  if (showChannelPredictions) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Kanal Tahminleri',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    _ChannelPredictionsSection(
                      eventId: widget.eventId,
                      highlightUserId: userId,
                    ),
                  ],
                  const SizedBox(height: 16),
                  const _ScoringRulesCard(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Colors.grey.shade600)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                color: highlight ? Colors.green.shade800 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelPredictionsSection extends ConsumerWidget {
  const _ChannelPredictionsSection({
    required this.eventId,
    this.highlightUserId,
  });

  final String eventId;
  final String? highlightUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predictionsAsync = ref.watch(channelPredictionsProvider(eventId));

    return Card(
      child: AsyncValueWidget(
        value: predictionsAsync,
        onRetry: () => ref.invalidate(channelPredictionsProvider(eventId)),
        data: (predictions) => ChannelPredictionsList(
          predictions: predictions,
          highlightUserId: highlightUserId,
        ),
      ),
    );
  }
}

class _ScoringRulesCard extends StatelessWidget {
  const _ScoringRulesCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Puanlama Kuralları',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Maç skoru — Kazanan/beraberlik: 1 puan'),
            Text('Maç skoru — Tam skor: 3 puan'),
            Text('Şampiyon: 10 puan'),
            Text('İkinci: 5 puan'),
            Text('Üçüncü: 3 puan'),
          ],
        ),
      ),
    );
  }
}
