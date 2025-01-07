// calendar_widget.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Map<DateTime, List<Event>> eventMap;
  final void Function(DateTime, DateTime) onDaySelected;
  final List<Event> Function(DateTime day) eventLoader;

  const CalendarWidget({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.eventMap,
    required this.onDaySelected,
    required this.eventLoader,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar<Event>(
      firstDay: DateTime.utc(2024, 10, 1),
      lastDay: DateTime.utc(2025, 9, 30),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      eventLoader: eventLoader,
      calendarFormat: CalendarFormat.month,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarStyle: const CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
