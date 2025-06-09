import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CohereAIService {
  static const String _apiKey = 'ndqRq03VFxPW82YvbiJ8yApTnukLEnpSew1K3dMU';
  static const String _baseUrl = 'https://api.cohere.ai/v1';
  static const String _model = 'command-r-plus';

  static const String _systemPrompt = '''
You are a helpful and responsible AI health assistant. Your name is "Swasthya Setu's AI health assistant". The user will describe their symptoms.
Your role is to:
1. Ask any necessary follow-up questions if the symptom description is vague.
2. Suggest possible causes or conditions (but do not provide a medical diagnosis).
3. Recommend whether the user should consult a healthcare professional.
Be clear, concise, and informative. Always include a disclaimer that this is not a substitute for professional medical advice.
You can get the Response from the User both in English and Romanized Nepali. If you get response in Romanized Nepali, you should
 give the output in Romanized Nepali. If you get response in Nepali Language, you should give the output in Nepali Language. If
   get response in English, you should give the output in English. and If you get mixed then give in Nepali. Provide me the specialist name too for the symptoms and also make response short not more than 75 words''';

  // Chat history to maintain conversation context
  List<Map<String, String>> _chatHistory = [];

  // Initialize chat with system prompt
  void initializeChat() {
    _chatHistory = [
      {"role": "SYSTEM", "message": _systemPrompt},
    ];
  }

  // Send message and get response
  Future<String> sendMessage(String userMessage) async {
    try {
      // Add user message to chat history
      _chatHistory.add({"role": "USER", "message": userMessage});

      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'message': userMessage,
          'model': _model,
          'chat_history': _chatHistory.where((msg) => msg['role'] != 'SYSTEM').toList(),
          'preamble': _systemPrompt,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['text'] ?? 'Sorry, I could not process your request.';
        
        // Add AI response to chat history
        _chatHistory.add({"role": "CHATBOT", "message": aiResponse});
        
        return aiResponse;
      } else {
        throw HttpException('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      return 'Sorry, I encountered an error while processing your request. Please try again later.';
    }
  }

  // Get chat history for display
  List<Map<String, String>> getChatHistory() {
    return _chatHistory.where((msg) => msg['role'] != 'SYSTEM').toList();
  }

  // Clear chat history
  void clearChat() {
    initializeChat();
  }

  // Check if chat is empty (only system prompt)
  bool isChatEmpty() {
    return _chatHistory.length <= 1;
  }
}
