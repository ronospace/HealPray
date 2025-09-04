import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Spiritual gradient background with floating elements
class SpiritualBackground extends StatelessWidget {
  const SpiritualBackground({
    super.key,
    required this.child,
    this.showFloatingElements = true,
  });

  final Widget child;
  final bool showFloatingElements;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.morningGradient,
      ),
      child: Stack(
        children: [
          // Floating spiritual elements
          if (showFloatingElements) ...[
            _buildFloatingElement(
              context,
              top: 100,
              left: 50,
              size: 20,
              opacity: 0.1,
            ),
            _buildFloatingElement(
              context,
              top: 200,
              right: 30,
              size: 15,
              opacity: 0.15,
            ),
            _buildFloatingElement(
              context,
              bottom: 150,
              left: 30,
              size: 25,
              opacity: 0.08,
            ),
            _buildFloatingElement(
              context,
              bottom: 300,
              right: 60,
              size: 18,
              opacity: 0.12,
            ),
            _buildFloatingElement(
              context,
              top: 300,
              left: 200,
              size: 12,
              opacity: 0.2,
            ),
          ],
          
          // Content
          child,
        ],
      ),
    );
  }

  Widget _buildFloatingElement(
    BuildContext context, {
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: _FloatingElement(
        size: size,
        opacity: opacity,
      ),
    );
  }
}

/// Individual floating element with animation
class _FloatingElement extends StatefulWidget {
  const _FloatingElement({
    required this.size,
    required this.opacity,
  });

  final double size;
  final double opacity;

  @override
  State<_FloatingElement> createState() => _FloatingElementState();
}

class _FloatingElementState extends State<_FloatingElement>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3 + (widget.size * 0.1).round()),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.5 + (_animation.value * 0.5),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(widget.opacity * _animation.value),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1 * _animation.value),
                  blurRadius: widget.size * 0.5,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
