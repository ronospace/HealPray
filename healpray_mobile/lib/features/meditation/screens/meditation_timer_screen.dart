import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/meditation_session.dart';
import '../services/meditation_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger.dart';
import '../widgets/meditation_timer_widget.dart';
import '../widgets/meditation_script_display.dart';
import '../widgets/meditation_controls.dart';

/// Main meditation timer screen
class MeditationTimerScreen extends ConsumerStatefulWidget {
  const MeditationTimerScreen({
    super.key,
    required this.session,
  });

  final MeditationSession session;

  @override
  ConsumerState<MeditationTimerScreen> createState() =>
      _MeditationTimerScreenState();
}

class _MeditationTimerScreenState extends ConsumerState<MeditationTimerScreen>
    with TickerProviderStateMixin {
  final MeditationService _meditationService = MeditationService.instance;

  StreamSubscription<MeditationSession>? _sessionSubscription;
  MeditationSession? _currentSession;

  late AnimationController _breathingController;
  late AnimationController _fadeController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _fadeAnimation;

  bool _isSessionActive = false;
  bool _showScript = true;
  int _currentScriptLine = 0;
  Timer? _scriptTimer;

  @override
  void initState() {
    super.initState();

    _currentSession = widget.session;
    _initializeAnimations();
    _listenToSessionUpdates();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPreparationPhase();
    });
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    _scriptTimer?.cancel();
    _breathingController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
  }

  void _listenToSessionUpdates() {
    _sessionSubscription = _meditationService.currentSessionStream?.listen(
      (session) {
        if (mounted) {
          setState(() {
            _currentSession = session;
            _isSessionActive = session.state == MeditationState.active;
          });

          if (_isSessionActive && !_breathingController.isAnimating) {
            _startBreathingAnimation();
          } else if (!_isSessionActive && _breathingController.isAnimating) {
            _breathingController.stop();
          }
        }
      },
      onError: (error) {
        AppLogger.error('Session stream error', error);
        _showErrorSnackBar('Session update error: $error');
      },
    );
  }

  void _startPreparationPhase() async {
    setState(() {
      _showScript = true;
    });

    _fadeController.forward();

    // Show preparation screen for 10 seconds
    await Future.delayed(const Duration(seconds: 10));

    if (mounted) {
      _beginMeditation();
    }
  }

  void _beginMeditation() async {
    try {
      await _meditationService.beginMeditation();
      _startBreathingAnimation();
      _startScriptTimer();

      setState(() {
        _isSessionActive = true;
      });
    } catch (e) {
      AppLogger.error('Failed to begin meditation', e);
      _showErrorSnackBar('Failed to start meditation: $e');
    }
  }

  void _startBreathingAnimation() {
    _breathingController.repeat(reverse: true);
  }

  void _startScriptTimer() {
    if (_currentSession?.scriptContent == null) return;

    final script = _currentSession!.scriptContent!;
    final lines =
        script.split('\n').where((line) => line.trim().isNotEmpty).toList();

    if (lines.isEmpty) return;

    final totalDuration = _currentSession!.targetDurationMinutes * 60;
    final intervalPerLine = totalDuration / lines.length;

    _scriptTimer = Timer.periodic(
      Duration(seconds: intervalPerLine.ceil()),
      (timer) {
        if (_currentScriptLine < lines.length - 1) {
          setState(() {
            _currentScriptLine++;
          });
        } else {
          timer.cancel();
        }
      },
    );
  }

  void _pauseMeditation() async {
    try {
      await _meditationService.pauseMeditation();
      _breathingController.stop();
      _scriptTimer?.cancel();
    } catch (e) {
      AppLogger.error('Failed to pause meditation', e);
      _showErrorSnackBar('Failed to pause: $e');
    }
  }

  void _resumeMeditation() async {
    try {
      await _meditationService.resumeMeditation();
      _startBreathingAnimation();
      _startScriptTimer();
    } catch (e) {
      AppLogger.error('Failed to resume meditation', e);
      _showErrorSnackBar('Failed to resume: $e');
    }
  }

  void _endMeditation() async {
    try {
      final completedSession =
          await _meditationService.completeMeditationSession();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MeditationCompletionScreen(
              session: completedSession,
            ),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Failed to end meditation', e);
      _showErrorSnackBar('Failed to end meditation: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _toggleScript() {
    setState(() {
      _showScript = !_showScript;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentSession == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Session info
            _buildSessionHeader(),

            // Main timer area
            Expanded(
              flex: 3,
              child: AnimatedBuilder(
                animation: _breathingAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isSessionActive ? _breathingAnimation.value : 1.0,
                    child: MeditationTimerWidget(
                      session: _currentSession!,
                      isActive: _isSessionActive,
                    ),
                  );
                },
              ),
            ),

            // Script display
            if (_showScript)
              Expanded(
                flex: 2,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: MeditationScriptDisplay(
                    session: _currentSession!,
                  ),
                ),
              ),

            // Controls
            Expanded(
              flex: 1,
              child: MeditationControls(
                session: _currentSession!,
                onPause: _pauseMeditation,
                onPlay: _resumeMeditation,
                onStop: _endMeditation,
                onComplete: _endMeditation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('End Meditation?'),
              content: const Text(
                  'Are you sure you want to end this meditation session?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _endMeditation();
                  },
                  child: const Text('End Session'),
                ),
              ],
            ),
          );
        },
      ),
      title: Text(
        _currentSession?.title ?? 'Meditation',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSessionHeader() {
    final session = _currentSession!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Text(
            session.typeDisplayName,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                session.typeIcon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Text(
                '${session.targetDurationMinutes} minutes',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (session.state == MeditationState.preparing) ...[
            const SizedBox(height: 16),
            const Text(
              'Preparing your meditation space...',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            const LinearProgressIndicator(
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.healingTeal),
            ),
          ],
        ],
      ),
    );
  }
}

/// Meditation completion screen
class MeditationCompletionScreen extends StatefulWidget {
  const MeditationCompletionScreen({
    super.key,
    required this.session,
  });

  final MeditationSession session;

  @override
  State<MeditationCompletionScreen> createState() =>
      _MeditationCompletionScreenState();
}

class _MeditationCompletionScreenState
    extends State<MeditationCompletionScreen> {
  final TextEditingController _reflectionController = TextEditingController();
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('Meditation Complete'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Completion celebration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.healingTeal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 60,
                color: AppTheme.healingTeal,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Well Done!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'You completed a ${widget.session.formattedActualDuration} ${widget.session.typeDisplayName.toLowerCase()}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Session stats
            _buildStatsCard(),

            const SizedBox(height: 32),

            // Rating
            _buildRatingSection(),

            const SizedBox(height: 32),

            // Reflection
            _buildReflectionSection(),

            const SizedBox(height: 40),

            // Actions
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final session = widget.session;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Duration', session.formattedActualDuration),
                _buildStatItem('Completion',
                    '${(session.completionPercentage * 100).round()}%'),
                _buildStatItem('Type', session.typeIcon),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppTheme.healingTeal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How was your meditation?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = starIndex;
                    });
                  },
                  child: Icon(
                    starIndex <= _rating ? Icons.star : Icons.star_border,
                    size: 40,
                    color: AppTheme.sunriseGold,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reflection (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reflectionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'How do you feel? What insights did you gain?',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // Save feedback and navigate home
              _saveFeedbackAndFinish();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.healingTeal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Complete Session',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          },
          child: const Text(
            'Skip feedback and continue',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _saveFeedbackAndFinish() async {
    try {
      // Save rating and reflection to the session
      final meditationService = MeditationService.instance;
      await meditationService.completeMeditationSession(
        rating: _rating,
        reflection: _reflectionController.text.trim().isNotEmpty
            ? _reflectionController.text.trim()
            : null,
      );
      
      AppLogger.info('Meditation feedback saved: rating=$_rating');

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
      }
    } catch (e) {
      AppLogger.error('Failed to save meditation feedback', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save feedback: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
