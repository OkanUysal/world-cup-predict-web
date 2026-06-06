import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/async_value_widget.dart';
import '../../providers/events_provider.dart';
import '../../widgets/event_card.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tahminler'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Açık'),
              Tab(text: 'Bekleyen'),
              Tab(text: 'Tamamlanan'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _EventsList(status: 'open', emptyMessage: 'Açık tahmin bulunmuyor'),
            _EventsList(
              status: 'pending',
              emptyMessage: 'Bekleyen tahmin bulunmuyor',
            ),
            _EventsList(
              status: 'completed',
              emptyMessage: 'Tamamlanan tahmin bulunmuyor',
            ),
          ],
        ),
      ),
    );
  }
}

class _EventsList extends ConsumerWidget {
  const _EventsList({
    required this.status,
    required this.emptyMessage,
  });

  final String status;
  final String emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider(status));

    return RefreshIndicator(
      onRefresh: () => ref.refresh(eventsProvider(status).future),
      child: AsyncValueWidget(
        value: eventsAsync,
        onRetry: () => ref.invalidate(eventsProvider(status)),
        data: (events) {
          if (events.isEmpty) {
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
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          emptyMessage,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final item = events[index];
              return EventCard(
                item: item,
                onTap: () => context.push('/events/${item.event.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
