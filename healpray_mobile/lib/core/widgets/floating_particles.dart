import 'dart:math';
import 'package:flutter/material.dart';

/// Floating particles animation for atmospheric background effects
class FloatingParticles extends StatefulWidget {
  const FloatingParticles({
    super.key,
    this.numberOfParticles = 30,
    this.colors = const [Colors.white, Color(0xFFE5F0FF)],
    this.minSize = 2.0,
    this.maxSize = 6.0,
  });

  final int numberOfParticles;
  final List<Color> colors;
  final double minSize;
  final double maxSize;

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Initialize particles
    for (int i = 0; i < widget.numberOfParticles; i++) {
      _particles.add(_createParticle());
    }
  }

  Particle _createParticle() {
    return Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: widget.minSize +
          _random.nextDouble() * (widget.maxSize - widget.minSize),
      color: widget.colors[_random.nextInt(widget.colors.length)]
          .withValues(alpha: 0.3 + _random.nextDouble() * 0.4),
      speedX: (_random.nextDouble() - 0.5) * 0.002,
      speedY: -0.001 - _random.nextDouble() * 0.002,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Update particle positions
        for (var particle in _particles) {
          particle.x += particle.speedX;
          particle.y += particle.speedY;

          // Reset particles that go off screen
          if (particle.y < -0.1) {
            particle.y = 1.1;
            particle.x = _random.nextDouble();
          }
          if (particle.x < -0.1 || particle.x > 1.1) {
            particle.x = _random.nextDouble();
            particle.y = 1.1;
          }
        }

        return CustomPaint(
          painter: _ParticlePainter(_particles),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  final double size;
  final Color color;
  final double speedX;
  final double speedY;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speedX,
    required this.speedY,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}
