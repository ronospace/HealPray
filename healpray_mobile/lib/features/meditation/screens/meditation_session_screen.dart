import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../core/widgets/adaptive_app_bar.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/app_theme.dart';
import 'dart:math' as math;

/// Meditation session model
class MeditationGuide {
  final String id;
  final String title;
  final String description;
  final int duration; // in minutes
  final String category;
  final List<Color> colors;
  final IconData icon;

  MeditationGuide({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.category,
    required this.colors,
    required this.icon,
  });
}

/// Advanced meditation session screen with timer and audio guides
class MeditationSessionScreen extends ConsumerStatefulWidget {
  const MeditationSessionScreen({super.key});

  @override
  ConsumerState<MeditationSessionScreen> createState() => _MeditationSessionScreenState();
}

class _MeditationSessionScreenState extends ConsumerState<MeditationSessionScreen> {
  final List<MeditationGuide> _guides = [
    MeditationGuide(
      id: '1',
      title: 'Morning Peace',
      description: 'Start your day with calm and clarity',
      duration: 10,
      category: 'Morning',
      colors: [AppTheme.sunriseGold, AppTheme.hopeOrange],
      icon: Icons.wb_sunny,
    ),
    MeditationGuide(
      id: '2',
      title: 'Breath Awareness',
      description: 'Focus on your breath and find inner stillness',
      duration: 15,
      category: 'Mindfulness',
      colors: [AppTheme.healingTeal, AppTheme.celestialCyan],
      icon: Icons.air,
    ),
    MeditationGuide(
      id: '3',
      title: 'Loving Kindness',
      description: 'Cultivate compassion for yourself and others',
      duration: 12,
      category: 'Heart',
      colors: [AppTheme.hopeOrange, AppTheme.sunriseGold],
      icon: Icons.favorite,
    ),
    MeditationGuide(
      id: '4',
      title: 'Body Scan',
      description: 'Release tension and relax deeply',
      duration: 20,
      category: 'Relaxation',
      colors: [AppTheme.mysticalPurple, AppTheme.sacredBlue],
      icon: Icons.self_improvement,
    ),
    MeditationGuide(
      id: '5',
      title: 'Scripture Meditation',
      description: 'Meditate on God\'s word and truth',
      duration: 15,
      category: 'Spiritual',
      colors: [AppTheme.wisdomGold, AppTheme.sunriseGold],
      icon: Icons.auto_stories,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdaptiveAppBar(
        title: const Text('Meditation'),
      ),
      body: AnimatedGradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Start Card
              GlassCard(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.healingTeal, AppTheme.celestialCyan],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Quick Meditation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start a 5-minute mindful breathing session',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _startSession(
                        MeditationGuide(
                          id: 'quick',
                          title: 'Quick Session',
                          description: 'Mindful breathing',
                          duration: 5,
                          category: 'Quick',
                          colors: [AppTheme.healingTeal, AppTheme.celestialCyan],
                          icon: Icons.timer,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.healingTeal,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Start Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Today's Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.today,
                      label: 'Today',
                      value: '15 min',
                      color: AppTheme.sunriseGold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.local_fire_department,
                      label: 'Streak',
                      value: '7 days',
                      color: AppTheme.hopeOrange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Guided Meditations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Meditation Guides List
              ...(_guides.map((guide) => _buildGuideCard(guide))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return GlassCard(
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard(MeditationGuide guide) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _startSession(guide),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: guide.colors),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(guide.icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guide.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    guide.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${guide.duration} min',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          guide.category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  void _startSession(MeditationGuide guide) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MeditationTimerScreen(guide: guide),
      ),
    );
  }
}

/// Meditation Timer Screen with active session
class MeditationTimerScreen extends StatefulWidget {
  final MeditationGuide guide;

  const MeditationTimerScreen({super.key, required this.guide});

  @override
  State<MeditationTimerScreen> createState() => _MeditationTimerScreenState();
}

class _MeditationTimerScreenState extends State<MeditationTimerScreen>
    with TickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  late AnimationController _pulseController;
  late AnimationController _breathController;
  String _breathPhase = 'Breathe In';

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.guide.duration * 60;
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _breathPhase = 'Breathe Out');
          _breathController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          setState(() => _breathPhase = 'Breathe In');
          _breathController.forward();
        }
      });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _breathController.forward();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _completeSession();
      }
    });
  }

  void _pauseTimer() {
    setState(() => _isRunning = false);
    _timer?.cancel();
    _breathController.stop();
  }

  void _completeSession() {
    _timer?.cancel();
    _breathController.stop();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.mysticalPurple.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Session Complete! 🎉', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You\'ve completed your meditation session.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.self_improvement, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    '${widget.guide.duration} minutes',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Time meditating',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.healingTeal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String get _timeString {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isRunning) {
          _pauseTimer();
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppTheme.mysticalPurple.withValues(alpha: 0.95),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('End Session?', style: TextStyle(color: Colors.white)),
              content: const Text(
                'Your progress will not be saved.',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Continue', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('End'),
                ),
              ],
            ),
          );
          return shouldExit ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AdaptiveAppBar(
          title: Text(widget.guide.title),
        ),
        body: AnimatedGradientBackground(
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Breathing Circle Animation
                        AnimatedBuilder(
                          animation: _breathController,
                          builder: (context, child) {
                            return Container(
                              width: 200 + (_breathController.value * 50),
                              height: 200 + (_breathController.value * 50),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: widget.guide.colors,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.guide.colors[0].withValues(alpha: 0.5),
                                    blurRadius: 30 + (_breathController.value * 20),
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _timeString,
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (_isRunning) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        _breathPhase,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 60),

                        // Control Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isRunning)
                              FloatingActionButton(
                                onPressed: _pauseTimer,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                child: const Icon(Icons.pause, size: 32),
                              )
                            else
                              FloatingActionButton.large(
                                onPressed: _toggleTimer,
                                backgroundColor: AppTheme.healingTeal,
                                child: const Icon(Icons.play_arrow, size: 48),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Info
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: GlassCard(
                    child: Column(
                      children: [
                        Text(
                          widget.guide.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Find a comfortable position and focus on your breath',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
