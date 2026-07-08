import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../services/ai_service.dart';
import '../services/api_key_service.dart';
import '../services/gemini_ai_service.dart';
import 'settings_screen.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final AIService _mockAiService = AIService();
  final ApiKeyService _apiKeyService = ApiKeyService();
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  bool _useGemini = false;
  GeminiAIService? _geminiService;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadApiKey() async {
    final key = await _apiKeyService.getGeminiApiKey();
    if (mounted) {
      setState(() {
        _useGemini = key != null && key.isNotEmpty;
        if (_useGemini) {
          _geminiService = GeminiAIService(apiKey: key!);
        }
      });
    }
    _addBotMessage(_getGreetingMessage());
  }

  String _getGreetingMessage() {
    if (_useGemini) {
      return "Hi! I'm powered by Gemini. Ask me about your tasks, schedule, or priorities.";
    }
    return '${_mockAiService.getGreeting()} I\'m your AI planner assistant. Add your Gemini API key in Settings for smarter responses, or use me in offline mode.';
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add({'isUser': false, 'text': text});
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'isUser': true, 'text': text});
      _isTyping = true;
    });
    _messageController.clear();

    final provider = Provider.of<TaskProvider>(context, listen: false);
    String response;

    if (_useGemini && _geminiService != null) {
      response = await _geminiService!.sendMessage(text, provider.tasks);
    } else {
      // Add a small delay for better UX in mock mode
      await Future.delayed(const Duration(milliseconds: 600));
      response = _mockAiService.getAIResponse(text, provider.tasks);
    }

    setState(() {
      _isTyping = false;
      _addBotMessage(response);
    });
  }

  Future<void> _quickAction(String type) async {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    String response;

    setState(() => _isTyping = true);

    if (_useGemini && _geminiService != null) {
      switch (type) {
        case 'plan':
          response = await _geminiService!.generateDailyPlan(provider.tasks);
          break;
        case 'ideas':
          response = await _geminiService!.sendMessage(
            'Suggest 3 productive tasks or habits I should add to my planner.',
            provider.tasks,
          );
          break;
        case 'priority':
          response = await _geminiService!.sendMessage(
            'What should be my top priority right now based on my pending tasks?',
            provider.tasks,
          );
          break;
        default:
          response = 'How can I help?';
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 600));
      switch (type) {
        case 'plan':
          response = _mockAiService.generateDailyPlan(provider.tasks);
          break;
        case 'ideas':
          response = _mockAiService.suggestTaskIdeas();
          break;
        case 'priority':
          response = _mockAiService.getAIResponse('what is my top priority', provider.tasks);
          break;
        default:
          response = 'How can I help?';
      }
    }

    setState(() {
      _isTyping = false;
      _addBotMessage(response);
    });
  }

  void _openSettings() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const SettingsScreen()))
        .then((_) => _loadApiKey());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome),
            const SizedBox(width: 8),
            const Text('AI Assistant'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _openSettings,
              tooltip: 'Settings',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.today, size: 18),
                  label: const Text('Plan my day'),
                  onPressed: () => _quickAction('plan'),
                ),
                ActionChip(
                  avatar: const Icon(Icons.lightbulb, size: 18),
                  label: const Text('Task ideas'),
                  onPressed: () => _quickAction('ideas'),
                ),
                ActionChip(
                  avatar: const Icon(Icons.flag, size: 18),
                  label: const Text('Top priority'),
                  onPressed: () => _quickAction('priority'),
                ),
              ],
            ),
          ),
          if (!_useGemini)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Card(
                color: Colors.amber[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Running in offline mode. Add a Gemini API key in Settings for AI-powered responses.',
                          style: TextStyle(color: Colors.orange[900], fontSize: 12),
                        ),
                      ),
                      TextButton(
                        onPressed: _openSettings,
                        child: const Text('Add Key'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'] as bool;
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('AI is typing...', style: TextStyle(color: Colors.grey)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask your AI assistant...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
