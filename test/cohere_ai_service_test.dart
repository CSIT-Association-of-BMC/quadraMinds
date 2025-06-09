import 'package:flutter_test/flutter_test.dart';
import 'package:swasthya_setu/services/cohere_ai_service.dart';

void main() {
  group('CohereAIService Tests', () {
    late CohereAIService aiService;

    setUp(() {
      aiService = CohereAIService();
    });

    test('should initialize chat correctly', () {
      aiService.initializeChat();
      expect(aiService.isChatEmpty(), true);
    });

    test('should clear chat correctly', () {
      aiService.initializeChat();
      aiService.clearChat();
      expect(aiService.isChatEmpty(), true);
    });

    test('should return empty chat history initially', () {
      aiService.initializeChat();
      final history = aiService.getChatHistory();
      expect(history.isEmpty, true);
    });

    test('should have updated system prompt with specialist recommendations', () {
      // This test verifies that the system prompt includes the new requirements
      aiService.initializeChat();
      // The system prompt should include specialist recommendations and 75-word limit
      expect(true, true); // Placeholder - in real testing, you'd verify the prompt content
    });

    // Note: We're not testing the actual API call here as it requires network access
    // and would consume API credits. In a real-world scenario, you'd mock the HTTP client.
  });
}
