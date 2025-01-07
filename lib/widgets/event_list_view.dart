import 'package:flutter/material.dart';
import '../models/event.dart';

class EventListView extends StatelessWidget {
  final List<Event> events;

  const EventListView({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return events.isEmpty
        ? const Center(child: Text('No events for this day.'))
        : ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(event.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${event.date.toLocal().toIso8601String().split('T').first} at ${event.time}'),
                  trailing: Text(event.location),
                ),
              );
            },
          );
  }
}
