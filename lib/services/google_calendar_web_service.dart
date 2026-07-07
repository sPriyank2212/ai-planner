import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import '../models/calendar_event.dart';
import '../models/task.dart';
import 'calendar_sync_service.dart';

/// Syncs with Google Calendar on web via OAuth.
///
/// To use this on web:
/// 1. Create a Google Cloud project
/// 2. Enable Google Calendar API
/// 3. Create OAuth 2.0 web client ID
/// 4. Replace [clientId] below with your client ID
class GoogleCalendarWebService implements CalendarSyncService {
  static const String clientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? clientId : null,
    scopes: [gcal.CalendarApi.calendarEventsScope],
  );

  gcal.CalendarApi? _calendarApi;

  @override
  bool get isSupported => kIsWeb;

  @override
  Future<bool> requestPermissions() async {
    if (!isSupported) return false;
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return false;
      final authClient = await _googleSignIn.authenticatedClient();
      if (authClient == null) return false;
      _calendarApi = gcal.CalendarApi(authClient);
      return true;
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      return false;
    }
  }

  @override
  Future<List<CalendarEvent>> fetchEvents(DateTime start, DateTime end) async {
    if (!isSupported || _calendarApi == null) return [];

    try {
      final events = await _calendarApi!.events.list(
        'primary',
        timeMin: start.toUtc(),
        timeMax: end.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );

      return (events.items ?? []).map((e) {
        final startTime = e.start?.dateTime?.toLocal() ??
            e.start?.date?.toLocal() ??
            start;
        final endTime = e.end?.dateTime?.toLocal() ?? e.end?.date?.toLocal();

        return CalendarEvent(
          id: e.id ?? '',
          title: e.summary ?? 'Untitled Event',
          description: e.description,
          start: startTime,
          end: endTime,
          isAllDay: e.start?.date != null,
          calendarId: 'primary',
          calendarName: 'Google Calendar',
        );
      }).toList();
    } catch (e) {
      debugPrint('Fetch Google Calendar events error: $e');
      return [];
    }
  }

  @override
  Future<bool> createEventFromTask(Task task) async {
    if (!isSupported || _calendarApi == null || task.dueDate == null) return false;

    try {
      final event = gcal.Event(
        summary: task.title,
        description: task.description,
        start: gcal.EventDateTime(
          dateTime: task.dueDate!.toUtc(),
        ),
        end: gcal.EventDateTime(
          dateTime: task.dueDate!.add(const Duration(hours: 1)).toUtc(),
        ),
      );

      await _calendarApi!.events.insert(event, 'primary');
      return true;
    } catch (e) {
      debugPrint('Create Google Calendar event error: $e');
      return false;
    }
  }
}
