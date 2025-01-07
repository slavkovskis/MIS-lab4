import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/event_list_view.dart';
import 'add_event_screen.dart';
import 'map_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final EventService _eventService = EventService();
  late Map<DateTime, List<Event>> _eventMap;

  @override
  void initState() {
    super.initState();
    _eventMap = _eventService.getEventMap();
  }

  void _refreshEvents() {
    setState(() {
      _eventMap = _eventService.getEventMap();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Event> events = _eventService.getEventsForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapScreen(events: events),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          CalendarWidget(
            selectedDay: _selectedDay,
            focusedDay: _focusedDay,
            eventMap: _eventMap,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              return _eventMap[DateTime(day.year, day.month, day.day)] ?? [];
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: EventListView(events: events),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEventScreen(
                eventService: _eventService,
                onEventAdded: _refreshEvents,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
