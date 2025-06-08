import 'package:flutter/material.dart';
import 'onboarding_data.dart';

class OnboardingPage extends StatefulWidget {
  final OnboardingData data;
  final bool isActive;

  const OnboardingPage({super.key, required this.data, this.isActive = false});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _titleController;
  late AnimationController _descriptionController;

  late Animation<double> _iconFadeAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _descriptionFadeAnimation;

  late Animation<Offset> _iconSlideAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<Offset> _descriptionSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _titleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _descriptionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize fade animations
    _iconFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeInOut),
    );

    _descriptionFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _descriptionController, curve: Curves.easeInOut),
    );

    // Initialize slide animations
    _iconSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeOutCubic),
    );

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
    );

    _descriptionSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _descriptionController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void didUpdateWidget(OnboardingPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      _startAnimations();
    } else if (!widget.isActive && oldWidget.isActive) {
      _resetAnimations();
    }
  }

  void _startAnimations() async {
    // Reset all animations first
    _resetAnimations();

    // Start staggered animations
    _iconController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _titleController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _descriptionController.forward();
  }

  void _resetAnimations() {
    _iconController.reset();
    _titleController.reset();
    _descriptionController.reset();
  }

  @override
  void dispose() {
    _iconController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Start animations if this page is active
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAnimations();
      });
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.data.backgroundColor,
            widget.data.backgroundColor.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Icon Container
              SlideTransition(
                position: _iconSlideAnimation,
                child: FadeTransition(
                  opacity: _iconFadeAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.data.iconColor.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.data.icon,
                      size: 60,
                      color: widget.data.iconColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Animated Title
              SlideTransition(
                position: _titleSlideAnimation,
                child: FadeTransition(
                  opacity: _titleFadeAnimation,
                  child: Text(
                    widget.data.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Animated Description
              SlideTransition(
                position: _descriptionSlideAnimation,
                child: FadeTransition(
                  opacity: _descriptionFadeAnimation,
                  child: Text(
                    widget.data.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF5D6D7E),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
