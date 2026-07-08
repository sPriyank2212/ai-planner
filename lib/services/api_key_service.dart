import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyService {
  static const String _geminiApiKey = 'gemini_api_key';

  Future<String?> getGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString(_geminiApiKey);
    return key?.isNotEmpty == true ? key : null;
  }

  Future<void> setGeminiApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiApiKey, apiKey.trim());
  }

  Future<void> clearGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_geminiApiKey);
  }
}
