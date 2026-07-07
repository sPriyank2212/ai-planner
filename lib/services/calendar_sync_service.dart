import '../models/calendar_event.dart';
import '../models/task.dart';

/// Abstract interface for calendar synchronization.
/// Implemented per-platform (mobile device calendars, Google Calendar web, etc.).
abstract class CalendarSyncService {
  /// Returns true if the platform is supported by this service.
  bool get isSupported;

  /// Request required permissions from the user.
  Future<bool> requestPermissions();

  /// Fetch calendar events between [start] and [end].
  Future<List<CalendarEvent>> fetchEvents(DateTime start, DateTime end);

  /// Create a calendar event from a task. Returns true on success.
  Future<bool> createEventFromTask(Task task);
}
