import 'package:flutter/material.dart';

class FloatingAIAssistant extends StatefulWidget {
  const FloatingAIAssistant({super.key});

  @override
  State<FloatingAIAssistant> createState() => _FloatingAIAssistantState();
}

class _FloatingAIAssistantState extends State<FloatingAIAssistant>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isPressed = false;

  // Draggable position variables
  double _xPosition = 0.0;
  double _yPosition = 0.0;
  bool _isDragging = false;
  double _totalDragDistance = 0.0;
  bool _isInDefaultPosition = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Initialize position after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePosition();
    });
  }

  void _initializePosition() {
    final screenSize = MediaQuery.of(context).size;
    setState(() {
      // Default fixed starting position - bottom right corner
      _xPosition =
          screenSize.width - 80; // 20px from right edge + 60px button width
      _yPosition =
          screenSize.height - 180; // Above bottom navigation with more space
    });
  }

  void _resetToDefaultPosition() {
    _initializePosition();
    setState(() {
      _isInDefaultPosition = true;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isPressed = true;
      _totalDragDistance = 0.0;
    });
    _animationController.forward();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final screenSize = MediaQuery.of(context).size;
    final dragDistance = details.delta.distance;

    setState(() {
      _totalDragDistance += dragDistance;

      // Only start dragging if moved more than 10 pixels
      if (_totalDragDistance > 10) {
        _isDragging = true;
        _isInDefaultPosition = false; // Mark as moved from default
      }

      // Update position with bounds checking
      _xPosition = (_xPosition + details.delta.dx).clamp(
        0.0,
        screenSize.width - 60,
      );
      _yPosition = (_yPosition + details.delta.dy).clamp(
        0.0,
        screenSize.height - 60,
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();

    // If it was just a tap (minimal drag), show AI options
    if (_totalDragDistance <= 10) {
      _showAIAssistantOptions();
    }

    setState(() {
      _isDragging = false;
      _totalDragDistance = 0.0;
    });
  }

  void _onTap() {
    if (!_isDragging) {
      _showAIAssistantOptions();
    }
  }

  void _onLongPress() {
    // Reset to default position on long press
    _resetToDefaultPosition();

    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('AI Assistant moved to default position'),
        backgroundColor: const Color(0xFF667EEA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAIAssistantOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildAIAssistantModal(),
    );
  }

  Widget _buildAIAssistantModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header with AI icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667EEA),
                  Color(0xFF764BA2),
                  Color(0xFFE73C7E),
                  Color(0xFF23A6D5),
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 36,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'AI Health Assistant',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'How can I help you today?',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 32),

          // AI Assistant Options
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildAIOption(
                    'Symptom Checker',
                    'Describe your symptoms and get health insights',
                    Icons.health_and_safety,
                    const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 16),
                  _buildAIOption(
                    'Find Doctors',
                    'Get personalized doctor recommendations',
                    Icons.person_search,
                    const Color(0xFF667EEA),
                  ),
                  const SizedBox(height: 16),
                  _buildAIOption(
                    'Health Tips',
                    'Get daily health tips and wellness advice',
                    Icons.tips_and_updates,
                    const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 16),
                  _buildAIOption(
                    'Emergency Guide',
                    'Quick first aid and emergency assistance',
                    Icons.emergency,
                    const Color(0xFFDC2626),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAIOption(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _showComingSoonSnackBar(title);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: const Color(0xFF667EEA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _xPosition,
      top: _yPosition,
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        onTap: _onTap,
        onLongPress: _onLongPress,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF667EEA), // Blue
                        Color(0xFF764BA2), // Purple
                        Color(0xFFE73C7E), // Pink
                        Color(0xFF23A6D5), // Light blue
                      ],
                      stops: [0.0, 0.3, 0.7, 1.0],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: const Color(0xFFE73C7E).withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 28,
                      ),
                      // Small indicator dot when moved from default position
                      if (!_isInDefaultPosition)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
