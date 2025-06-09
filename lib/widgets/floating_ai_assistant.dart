import 'package:flutter/material.dart';

class FloatingAIAssistant extends StatefulWidget {
  // Add parameters to define the restricted area bounds
  final double? restrictedTop;
  final double? restrictedBottom;
  final double? restrictedLeft;
  final double? restrictedRight;

  const FloatingAIAssistant({
    super.key,
    this.restrictedTop,
    this.restrictedBottom,
    this.restrictedLeft,
    this.restrictedRight,
  });

  @override
  State<FloatingAIAssistant> createState() => _FloatingAIAssistantState();
}

class _FloatingAIAssistantState extends State<FloatingAIAssistant>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _glowAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;

  // Draggable position variables
  double _xPosition = 0.0;
  double _yPosition = 0.0;
  double _totalDragDistance = 0.0;
  bool _isInDefaultPosition = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Glow animation controller - repeats every 2 seconds with smooth transitions
    _glowAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Smooth glow animation - creates a gentle breathing effect
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(
        parent: _glowAnimationController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Initialize position after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePosition();
    });
  }

  void _initializePosition() {
    final screenSize = MediaQuery.of(context).size;
    setState(() {
      // Calculate restricted bounds
      final double leftBound = widget.restrictedLeft ?? 0.0;
      final double rightBound = widget.restrictedRight ?? screenSize.width;
      final double topBound = widget.restrictedTop ?? 0.0;
      final double bottomBound = widget.restrictedBottom ?? screenSize.height;

      // Default fixed starting position within restricted area
      _xPosition = (rightBound - 80).clamp(leftBound, rightBound - 60);
      _yPosition = (bottomBound - 80).clamp(topBound, bottomBound - 60);
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
    _glowAnimationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
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
        _isInDefaultPosition = false; // Mark as moved from default
      }

      // Calculate restricted bounds
      final double leftBound = widget.restrictedLeft ?? 0.0;
      final double rightBound = widget.restrictedRight ?? screenSize.width;
      final double topBound = widget.restrictedTop ?? 0.0;
      final double bottomBound = widget.restrictedBottom ?? screenSize.height;

      // Update position with restricted bounds checking
      _xPosition = (_xPosition + details.delta.dx).clamp(
        leftBound,
        rightBound - 60,
      );
      _yPosition = (_yPosition + details.delta.dy).clamp(
        topBound,
        bottomBound - 60,
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _animationController.reverse();

    setState(() {
      _totalDragDistance = 0.0;
    });
  }

  void _onLongPress() {
    // Reset to default position on long press
    _resetToDefaultPosition();

    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Assistant moved to default position'),
        backgroundColor: const Color(0xFF667EEA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onTap() {
    // Optionally, you can trigger a haptic feedback or a subtle animation here
    // _animationController.forward().then((_) => _animationController.reverse());
    _showAIAssistantDialog();
  }

  void _showAIAssistantDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFF667EEA)),
              SizedBox(width: 8),
              Text(
                'AI Assistant',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8, // Responsive width
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Hello! How can I assist you today?',
                  style: TextStyle(fontSize: 15, color: Color(0xFF4B5563)),
                ),
                const SizedBox(height: 20),
                // Add more interactive elements here, like buttons or a text field
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    // TODO: Implement chat functionality or other actions
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Chat feature coming soon!'),
                      ),
                    );
                  },
                  child: const Text('Start Chat'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFF667EEA),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
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
        onLongPress: _onLongPress,
        onTap: _onTap, // Added onTap handler
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _animationController,
            _glowAnimationController,
          ]),
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
                      // Smooth animated glow effect - outer glow
                      BoxShadow(
                        color: const Color(0xFF667EEA).withValues(
                          alpha: 0.15 + (_glowAnimation.value * 0.25),
                        ),
                        blurRadius: 30 + (_glowAnimation.value * 20),
                        offset: const Offset(0, 0),
                        spreadRadius: 2 + (_glowAnimation.value * 8),
                      ),
                      // Inner glow for depth
                      BoxShadow(
                        color: const Color(
                          0xFFE73C7E,
                        ).withValues(alpha: 0.1 + (_glowAnimation.value * 0.2)),
                        blurRadius: 20 + (_glowAnimation.value * 15),
                        offset: const Offset(0, 0),
                        spreadRadius: 1 + (_glowAnimation.value * 5),
                      ),
                      // Subtle purple glow
                      BoxShadow(
                        color: const Color(0xFF764BA2).withValues(
                          alpha: 0.08 + (_glowAnimation.value * 0.15),
                        ),
                        blurRadius: 25 + (_glowAnimation.value * 18),
                        offset: const Offset(0, 0),
                        spreadRadius: 1 + (_glowAnimation.value * 6),
                      ),
                      // Static shadow for depth
                      BoxShadow(
                        color: const Color(0xFF667EEA).withValues(alpha: 0.15),
                        blurRadius: 12,
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
