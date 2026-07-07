class CalendarEvent {
  final String id;
  final String title;
  final String? description;
  final DateTime start;
  final DateTime? end;
  final bool isAllDay;
  final String calendarId;
  final String? calendarName;

  CalendarEvent({
    required this.id,
    required this.title,
    this.description,
    required this.start,
    this.end,
    this.isAllDay = false,
    required this.calendarId,
    this.calendarName,
  });
}
