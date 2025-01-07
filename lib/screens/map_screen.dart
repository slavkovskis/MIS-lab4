import 'package:flutter/material.dart';
import '../models/event.dart';
import '../widgets/map_widget.dart';

class MapScreen extends StatelessWidget {
  final List<Event> events;

  const MapScreen({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map of Exams')),
      body: MapWidget(events: events),
    );
  }
}
