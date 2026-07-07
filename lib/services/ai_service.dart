import 'dart:math';
import '../models/task.dart';

/// AI Service for the planner assistant.
/// Currently uses local mock intelligence for the MVP.
/// Replace [getAIResponse] with a real API call (OpenAI, Gemini, etc.) for production.
class AIService {
  final Random _random = Random();

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }

  String generateDailyPlan(List<Task> tasks) {
    if (tasks.isEmpty) {
      return 'You have no tasks today. Enjoy your free time! 🎉';
    }

    final pending = tasks.where((t) => !t.isCompleted).toList();
    final completed = tasks.where((t) => t.isCompleted).length;

    if (pending.isEmpty) {
      return 'All caught up! You\'ve completed ${tasks.length} tasks. Great job! 🌟';
    }

    pending.sort((a, b) {
      final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
      return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
    });

    final topTask = pending.first;
    final buffer = StringBuffer();
    buffer.writeln('${getGreeting()} Here\'s your focus plan:');
    buffer.writeln('');
    buffer.writeln('🎯 Top priority: **${topTask.title}**');
    buffer.writeln('📊 ${pending.length} tasks remaining, $completed completed.');
    buffer.writeln('');
    buffer.writeln('Suggested order:');
    for (var i = 0; i < pending.length && i < 5; i++) {
      final task = pending[i];
      final icon = task.priority == 'high' ? '🔴' : task.priority == 'medium' ? '🟡' : '🟢';
      buffer.writeln('$icon ${i + 1}. ${task.title}');
    }

    return buffer.toString();
  }

  String suggestTaskIdeas() {
    final ideas = [
      'Review your weekly goals 🎯',
      'Drink a glass of water 💧',
      'Take a 10-minute walk 🚶',
      'Plan tomorrow\'s top 3 priorities 📝',
      'Clean your workspace for 5 minutes 🧹',
      'Read something educational for 15 minutes 📚',
      'Reach out to a friend or colleague 🤝',
      'Practice mindfulness for 5 minutes 🧘',
    ];

    ideas.shuffle(_random);
    final selected = ideas.take(3);
    return 'Here are some ideas to boost your productivity:\n\n${selected.map((i) => '• $i').join('\n')}';
  }

  String getAIResponse(String userMessage, List<Task> tasks) {
    final lower = userMessage.toLowerCase();

    if (lower.contains('plan') || lower.contains('schedule') || lower.contains('today')) {
      return generateDailyPlan(tasks);
    }

    if (lower.contains('idea') || lower.contains('suggest') || lower.contains('what should i do')) {
      return suggestTaskIdeas();
    }

    if (lower.contains('hello') || lower.contains('hi') || lower.contains('hey')) {
      return '${getGreeting()} I\'m your AI planner assistant. Ask me to plan your day, suggest tasks, or help prioritize!';
    }

    if (lower.contains('priority') || lower.contains('important')) {
      final pending = tasks.where((t) => !t.isCompleted).toList();
      if (pending.isEmpty) return 'No pending tasks. You\'re all clear! ✨';
      pending.sort((a, b) {
        final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
        return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
      });
      return 'Your most important task right now is: **${pending.first.title}** 🔥';
    }

    return 'I can help you plan your day, suggest tasks, or prioritize your to-do list. What would you like help with?';
  }
}
