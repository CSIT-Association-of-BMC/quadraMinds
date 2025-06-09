import 'package:flutter/material.dart';
import '../services/cohere_ai_service.dart';
import '../services/specialist_detection_service.dart';
import '../widgets/doctor_recommendation_widget.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final CohereAIService _aiService = CohereAIService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _aiService.initializeChat();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        text: "Hello! I'm Swasthya Setu's AI health assistant. Please describe your health symptoms (age, gender, duration, etc.) and I'll provide concise guidance with specialist recommendations. Remember, this is not a substitute for professional medical advice.",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await _aiService.sendMessage(message);

      // Detect if AI recommends a specialist
      final specialistRecommendation = SpecialistDetectionService.extractSpecialistRecommendation(response);

      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
          recommendedSpecialist: specialistRecommendation?['specialist'],
          specialistContext: specialistRecommendation?['context'],
        ));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Sorry, I encountered an error. Please try again.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _aiService.clearChat();
      _addWelcomeMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFF667EEA)),
            SizedBox(width: 8),
            Text(
              'AI Health Assistant',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF667EEA)),
            onPressed: _clearChat,
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: _messages[index]);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                  ),
                  SizedBox(width: 16),
                  Text('AI is thinking...'),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Describe symptoms (age, gender, duration)...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Color(0xFF667EEA)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  backgroundColor: const Color(0xFF667EEA),
                  mini: true,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? recommendedSpecialist;
  final String? specialistContext;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.recommendedSpecialist,
    this.specialistContext,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!message.isUser) ...[
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF667EEA),
                  child: Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? const Color(0xFF667EEA)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              if (message.isUser) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person, color: Colors.white, size: 16),
                ),
              ],
            ],
          ),
          // Show doctor recommendations if AI recommended a specialist
          if (!message.isUser && message.recommendedSpecialist != null)
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              margin: const EdgeInsets.only(left: 40, top: 8),
              child: DoctorRecommendationWidget(
                specialization: message.recommendedSpecialist!,
                context: message.specialistContext ?? '',
              ),
            ),
        ],
      ),
    );
  }
}
