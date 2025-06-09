import 'package:flutter/material.dart';

class SimpleDialogDemo extends StatelessWidget {
  const SimpleDialogDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Simple Dialog Demo'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667EEA),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _showSimpleDialog(context),
          child: const Text(
            'Show Simple Dialog',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  void _showSimpleDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.1),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.7,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            )),
            child: _buildSimpleDialog(context),
          ),
        );
      },
    );
  }

  Widget _buildSimpleDialog(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: screenSize.height * 0.1, // Responsive vertical margin
        ),
        constraints: BoxConstraints(
          maxWidth: 200, // Reduced size
          maxHeight: screenSize.height * 0.4, // Reduced height
          minWidth: 180,
          minHeight: 130,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18), // Slightly smaller radius
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 25,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: const Color(0xFF667EEA).withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 5),
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogHeader(context),
              Flexible(
                child: _buildBlankContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), // Reduced padding
      child: Row(
        children: [
          // Using the gradient icon design as requested
          Container(
            width: 28, // Reduced from 32
            height: 28,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
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
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 14, // Reduced from 16
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(5), // Reduced from 6
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(6), // Reduced from 8
              ),
              child: const Icon(
                Icons.close,
                color: Color(0xFF6B7280),
                size: 14, // Reduced from 16
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlankContent() {
    return Container(
      padding: const EdgeInsets.all(16), // Reduced from 20
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Completely blank content area as requested
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
