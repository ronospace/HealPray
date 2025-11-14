import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../../core/theme/app_theme.dart';

/// Animated splash screen with stunning multi-dimensional color transitions
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  
  // Multiple color animations for beautiful transitions
  late Animation<Color?> _bgColor1;
  late Animation<Color?> _bgColor2;
  late Animation<Color?> _bgColor3;
  late Animation<Color?> _accentColor;

  @override
  void initState() {
    super.initState();
    
    // Main animation controller
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    // Continuous pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    // Continuous rotation animation
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Fade in animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Scale animation with bounce
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );
    
    // Slide from bottom animation
    _slideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    
    // Pulse animation
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Rotation animation
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      _rotationController,
    );

    // Beautiful color transitions - from purple/pink to teal/blue
    _bgColor1 = ColorTween(
      begin: const Color(0xFF6B4CE6), // Deep Purple
      end: const Color(0xFF14B8A6), // Teal
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeInOut,
      ),
    );
    
    _bgColor2 = ColorTween(
      begin: const Color(0xFFEC4899), // Pink
      end: const Color(0xFF0EA5E9), // Sky Blue
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeInOut,
      ),
    );
    
    _bgColor3 = ColorTween(
      begin: const Color(0xFFF59E0B), // Amber
      end: const Color(0xFF8B5CF6), // Violet
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeInOut,
      ),
    );
    
    _accentColor = ColorTween(
      begin: const Color(0xFFFBBF24), // Golden
      end: const Color(0xFF10B981), // Emerald
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeInOut,
      ),
    );

    _mainController.forward();

    // Navigate to home after animation completes
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _mainController,
          _pulseController,
          _rotationController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // Multi-layered animated gradient background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _bgColor1.value ?? const Color(0xFF6B4CE6),
                        _bgColor2.value ?? const Color(0xFFEC4899),
                        _bgColor3.value ?? const Color(0xFFF59E0B),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              
              // Animated overlay gradient for depth
              Positioned.fill(
                child: Opacity(
                  opacity: 0.6,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topRight,
                        radius: 1.5,
                        colors: [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Rotating decorative circles in background
              Positioned.fill(
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: CustomPaint(
                    painter: _CirclesPainter(
                      color1: _accentColor.value ?? Colors.amber,
                      color2: _bgColor2.value ?? Colors.pink,
                    ),
                  ),
                ),
              ),
              
              // Main content
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated logo with pulse
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    Colors.white.withValues(alpha: 0.9),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _accentColor.value?.withValues(alpha: 0.4) ??
                                        Colors.amber.withValues(alpha: 0.4),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 30,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(70),
                                  child: Image.asset(
                                    'assets/logo/playstore_icon.png',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback to icon if image fails to load
                                      return ShaderMask(
                                        shaderCallback: (bounds) => LinearGradient(
                                          colors: [
                                            _bgColor1.value ?? const Color(0xFF6B4CE6),
                                            _bgColor2.value ?? const Color(0xFFEC4899),
                                          ],
                                        ).createShader(bounds),
                                        child: const Icon(
                                          Icons.favorite,
                                          size: 70,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // App name with gradient
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withValues(alpha: 0.95),
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'HealPray',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2.0,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 4),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Subtitle
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: const Text(
                              'Your Spiritual Companion',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 80),
                        
                        // Animated loading dots
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _LoadingDots(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Custom painter for decorative circles
class _CirclesPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  
  _CirclesPainter({required this.color1, required this.color2});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = color1.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    
    final paint2 = Paint()
      ..color = color2.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    
    // Draw decorative circles
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Animated loading dots widget
class _LoadingDots extends StatefulWidget {
  final Color color;
  
  const _LoadingDots({required this.color});
  
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            final scale = math.sin(value * math.pi) * 0.5 + 0.5;
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: 0.5 + scale,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
