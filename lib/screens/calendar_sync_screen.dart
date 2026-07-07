import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/calendar_event.dart';
import '../providers/task_provider.dart';
import '../services/calendar_service_factory.dart';
import '../services/calendar_sync_service.dart';

class CalendarSyncScreen extends StatefulWidget {
  const CalendarSyncScreen({super.key});

  @override
  State<CalendarSyncScreen> createState() => _CalendarSyncScreenState();
}

class _CalendarSyncScreenState extends State<CalendarSyncScreen> {
  final CalendarSyncService _service = CalendarServiceFactory.getService();
  bool _isLoading = false;
  String? _statusMessage;
  List<CalendarEvent> _events = [];

  Future<void> _loadEvents() async {
    if (!_service.isSupported) {
      setState(() {
        _statusMessage = 'Calendar sync is not supported on this platform yet.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Requesting calendar access...';
      _events = [];
    });

    final hasPermission = await _service.requestPermissions();
    if (!hasPermission) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Calendar permission denied. Please allow access in settings.';
      });
      return;
    }

    setState(() => _statusMessage = 'Fetching events...');

    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 1, now.day);
    final end = DateTime(now.year, now.month + 2, now.day);

    final events = await _service.fetchEvents(start, end);

    setState(() {
      _isLoading = false;
      _events = events;
      _statusMessage = events.isEmpty
          ? 'No calendar events found for the selected range.'
          : 'Found ${events.length} events.';
    });
  }

  Future<void> _importEvents() async {
    if (_events.isEmpty) return;

    setState(() => _isLoading = true);
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final imported = await provider.importCalendarEvents(_events);

    setState(() {
      _isLoading = false;
      _statusMessage = 'Imported $imported events as tasks.';
    });

    if (mounted && imported > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported $imported events as tasks')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Sync'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sync with your calendar',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Import events from Google Calendar, Outlook, or Apple Calendar and turn them into tasks.',
                    ),
                    const SizedBox(height: 16),
                    if (_service.isSupported)
                      FilledButton.icon(
                        onPressed: _isLoading ? null : _loadEvents,
                        icon: const Icon(Icons.sync),
                        label: const Text('Connect & Load Events'),
                      )
                    else
                      const Text(
                        'Not supported on this platform. Use mobile or web.',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_statusMessage != null)
              Text(
                _statusMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            if (_isLoading) const LinearProgressIndicator(),
            const SizedBox(height: 16),
            if (_events.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_events.length} events found',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  FilledButton(
                    onPressed: _isLoading ? null : _importEvents,
                    child: const Text('Import All'),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _events.isEmpty
                  ? const Center(
                      child: Text('Tap "Connect & Load Events" to get started'),
                    )
                  : ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        return ListTile(
                          leading: const Icon(Icons.event),
                          title: Text(event.title),
                          subtitle: Text(
                            '${DateFormat.yMMMd().add_jm().format(event.start)}'
                            '${event.calendarName != null ? ' • ${event.calendarName}' : ''}',
                          ),
                          trailing: event.isAllDay
                              ? const Chip(label: Text('ALL DAY'))
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
