import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/task.dart';

class GeminiAIService {
  final String apiKey;
  late final GenerativeModel _model;
  final List<Content> _chatHistory = [];

  GeminiAIService({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  String _buildSystemContext(List<Task> tasks) {
    final pending = tasks.where((t) => !t.isCompleted).toList();
    final completed = tasks.where((t) => t.isCompleted).toList();

    final buffer = StringBuffer();
    buffer.writeln('You are a helpful personal planner assistant.');
    buffer.writeln('The user has ${tasks.length} total tasks.');
    buffer.writeln('Pending tasks: ${pending.length}');
    buffer.writeln('Completed tasks: ${completed.length}');

    if (pending.isNotEmpty) {
      buffer.writeln('\nPending tasks:');
      for (final task in pending) {
        buffer.writeln('- ${task.title} (priority: ${task.priority}, due: ${task.dueDate?.toIso8601String() ?? 'no date'})');
      }
    }

    buffer.writeln('\nKeep responses concise, friendly, and actionable. Use emojis occasionally.');

    return buffer.toString();
  }

  Future<String> sendMessage(String message, List<Task> tasks) async {
    try {
      // Initialize chat with system context on first message
      if (_chatHistory.isEmpty) {
        _chatHistory.add(Content.text(_buildSystemContext(tasks)));
      }

      _chatHistory.add(Content.text(message));

      final chat = _model.startChat(history: _chatHistory);
      final response = await chat.sendMessage(Content.text(message));
      final text = response.text;

      if (text == null || text.isEmpty) {
        return 'Sorry, I got an empty response. Please try again.';
      }

      _chatHistory.add(Content.model([TextPart(text)]));
      return text;
    } catch (e) {
      debugPrint('Gemini API error: $e');
      return 'Error: ${e.toString().replaceAll(apiKey, '***')}';
    }
  }

  Future<String> generateDailyPlan(List<Task> tasks) async {
    final prompt = '''
Create a short daily plan based on these pending tasks:
${tasks.where((t) => !t.isCompleted).map((t) => '- ${t.title} (priority: ${t.priority}, due: ${t.dueDate?.toIso8601String() ?? 'no date'})').join('\n')}

Suggest the top 3 priorities and a simple schedule. Keep it brief.
''';

    return sendMessage(prompt, tasks);
  }

  void clearHistory() {
    _chatHistory.clear();
  }
}
