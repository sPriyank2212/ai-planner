import 'package:flutter/foundation.dart';
import 'calendar_sync_service.dart';
import 'device_calendar_service.dart';
import 'google_calendar_web_service.dart';

class CalendarServiceFactory {
  static CalendarSyncService getService() {
    if (kIsWeb) {
      return GoogleCalendarWebService();
    }
    return DeviceCalendarService();
  }
}
