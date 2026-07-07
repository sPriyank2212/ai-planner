import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/calendar_event.dart';
import '../models/task.dart';
import 'calendar_sync_service.dart';

/// Syncs with the device's native calendar on Android and iOS.
class DeviceCalendarService implements CalendarSyncService {
  final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin();

  @override
  bool get isSupported => defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Future<bool> requestPermissions() async {
    final result = await _plugin.requestPermissions();
    return result.data ?? false;
  }

  @override
  Future<List<CalendarEvent>> fetchEvents(DateTime start, DateTime end) async {
    if (!isSupported) return [];

    final permission = await requestPermissions();
    if (!permission) return [];

    final calendarsResult = await _plugin.retrieveCalendars();
    final calendars = calendarsResult.data ?? [];

    final List<CalendarEvent> events = [];

    for (final calendar in calendars) {
      if (calendar.id == null) continue;

      final eventsResult = await _plugin.retrieveEvents(
        calendar.id!,
        RetrieveEventsParams(
          startDate: start,
          endDate: end,
        ),
      );

      final calendarEvents = eventsResult.data ?? [];
      for (final event in calendarEvents) {
        if (event.eventId == null || event.title == null) continue;

        events.add(CalendarEvent(
          id: event.eventId!,
          title: event.title!,
          description: event.description,
          start: event.start ?? start,
          end: event.end,
          isAllDay: event.allDay ?? false,
          calendarId: calendar.id!,
          calendarName: calendar.name,
        ));
      }
    }

    return events;
  }

  @override
  Future<bool> createEventFromTask(Task task) async {
    if (!isSupported || task.dueDate == null) return false;

    final permission = await requestPermissions();
    if (!permission) return false;

    final calendarsResult = await _plugin.retrieveCalendars();
    final calendars = calendarsResult.data ?? [];
    final writableCalendar = calendars.firstWhere(
      (c) => c.isDefault ?? false,
      orElse: () => calendars.isNotEmpty ? calendars.first : Calendar(),
    );

    if (writableCalendar.id == null) return false;

    final start = task.dueDate != null
        ? tz.TZDateTime.from(task.dueDate!, tz.local)
        : null;
    final end = task.dueDate != null
        ? tz.TZDateTime.from(task.dueDate!.add(const Duration(hours: 1)), tz.local)
        : null;

    final event = Event(
      writableCalendar.id!,
      title: task.title,
      description: task.description,
      start: start,
      end: end,
      allDay: true,
    );

    final result = await _plugin.createOrUpdateEvent(event);
    return result?.isSuccess ?? false;
  }
}
