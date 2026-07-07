import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/calendar_event.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

class TaskProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final _uuid = const Uuid();

  List<Task> _tasks = [];
  bool _isLoaded = false;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoaded => _isLoaded;

  List<Task> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();
  List<Task> get todayTasks => _tasks.where((t) {
        if (t.dueDate == null) return false;
        final now = DateTime.now();
        return t.dueDate!.year == now.year &&
            t.dueDate!.month == now.month &&
            t.dueDate!.day == now.day;
      }).toList();

  Future<void> loadTasks() async {
    _tasks = await _storageService.loadTasks();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    String? description,
    DateTime? dueDate,
    String priority = 'medium',
    String? category,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      category: category,
      createdAt: DateTime.now(),
    );
    _tasks.add(task);
    await _save();
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await _save();
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      await _save();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _save();
  }

  Future<void> _save() async {
    await _storageService.saveTasks(_tasks);
    notifyListeners();
  }

  Future<int> importCalendarEvents(List<CalendarEvent> events) async {
    int imported = 0;
    for (final event in events) {
      // Skip duplicates by event id
      if (_tasks.any((t) => t.description?.contains(event.id) ?? false)) continue;

      final task = Task(
        id: _uuid.v4(),
        title: event.title,
        description: '${event.description ?? ''}\n\n[Imported from calendar: ${event.id}]'.trim(),
        dueDate: event.start,
        priority: 'medium',
        createdAt: DateTime.now(),
      );
      _tasks.add(task);
      imported++;
    }
    if (imported > 0) await _save();
    return imported;
  }

  List<Task> getTasksForDate(DateTime date) {
    return _tasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == date.year &&
          t.dueDate!.month == date.month &&
          t.dueDate!.day == date.day;
    }).toList();
  }
}
