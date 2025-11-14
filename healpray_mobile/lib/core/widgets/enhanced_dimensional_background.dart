import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

/// Enhanced dimensional gradient background with smooth transitions
/// Provides beautiful multi-layered backgrounds used throughout the app
class EnhancedDimensionalBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;
  final Duration animationDuration;
  final bool enableParticles;
  final bool enableRotation;
  
  const EnhancedDimensionalBackground({
    super.key,
    required this.child,
    this.colors,
    this.animationDuration = const Duration(seconds: 10),
    this.enableParticles = true,
    this.enableRotation = true,
  });

  @override
  State<EnhancedDimensionalBackground> createState() =>
      _EnhancedDimensionalBackgroundState();
}

class _EnhancedDimensionalBackgroundState
    extends State<EnhancedDimensionalBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Use provided colors or time-based gradient
    final gradientColors = widget.colors ?? AppTheme.getTimeBasedGradient();

    return Stack(
      children: [
        // Base gradient layer
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              );
            },
          ),
        ),

        // Overlay gradient for depth
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  Colors.white.withValues(alpha: isDark ? 0.05 : 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Rotating decorative shapes (if enabled)
        if (widget.enableRotation)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: CustomPaint(
                    painter: _DecorativeShapesPainter(
                      colors: gradientColors,
                      isDark: isDark,
                    ),
                  ),
                );
              },
            ),
          ),

        // Content
        widget.child,
      ],
    );
  }
}

/// Custom painter for decorative background shapes
class _DecorativeShapesPainter extends CustomPainter {
  final List<Color> colors;
  final bool isDark;

  _DecorativeShapesPainter({
    required this.colors,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = colors.first.withValues(alpha: isDark ? 0.05 : 0.08)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = colors.last.withValues(alpha: isDark ? 0.04 : 0.06)
      ..style = PaintingStyle.fill;

    // Draw multiple decorative circles
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      size.width * 0.3,
      paint1,
    );

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.7),
      size.width * 0.25,
      paint2,
    );

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.1),
      size.width * 0.2,
      paint1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
