import 'package:flutter/material.dart';
import 'floating_particles.dart';

/// Flow AI-style animated gradient background
/// Smooth transitions between colors based on time and context
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.gradientColors,
    this.animationDuration = const Duration(seconds: 3),
    this.enableParticles = true,
  });

  final Widget child;
  final List<Color>? gradientColors;
  final Duration animationDuration;
  final bool enableParticles;

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.gradientColors ?? _getTimeBasedColors();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
              stops: [
                0.0,
                _animation.value,
                1.0,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Floating particles layer
              if (widget.enableParticles)
                const Positioned.fill(
                  child: FloatingParticles(
                    numberOfParticles: 30,
                    colors: [Colors.white, Color(0xFFE5F0FF)],
                  ),
                ),
              // Content
              widget.child,
            ],
          ),
        );
      },
    );
  }

  List<Color> _getTimeBasedColors() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      // Morning - Sunrise gradient
      return [
        const Color(0xFFffeaa7),
        const Color(0xFFfab1a0),
        const Color(0xFFfd79a8),
      ];
    } else if (hour >= 12 && hour < 17) {
      // Afternoon - Bright gradient
      return [
        const Color(0xFF4ECDC4),
        const Color(0xFF667eea),
        const Color(0xFF764ba2),
      ];
    } else if (hour >= 17 && hour < 21) {
      // Evening - Sunset gradient
      return [
        const Color(0xFFfdcb6e),
        const Color(0xFFe17055),
        const Color(0xFFd63031),
      ];
    } else {
      // Night - Deep gradient
      return [
        const Color(0xFF2d3436),
        const Color(0xFF6c5ce7),
        const Color(0xFF74b9ff),
      ];
    }
  }
}
