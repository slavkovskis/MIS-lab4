import '../models/event.dart';

class EventService {
  final List<Event> _events = [];

  void addEvent(Event event) {
    _events.add(event);
  }

  List<Event> getEventsForDay(DateTime day) {
    return _events.where((event) {
      return event.date.year == day.year &&
          event.date.month == day.month &&
          event.date.day == day.day;
    }).toList();
  }

  Map<DateTime, List<Event>> getEventMap() {
    Map<DateTime, List<Event>> eventMap = {};
    for (var event in _events) {
      final date = DateTime(event.date.year, event.date.month, event.date.day);
      if (eventMap[date] == null) {
        eventMap[date] = [];
      }
      eventMap[date]!.add(event);
    }
    return eventMap;
  }
}
