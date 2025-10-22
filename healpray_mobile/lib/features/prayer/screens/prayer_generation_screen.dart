import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/enhanced_glass_card.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../shared/models/prayer.dart';
import '../services/prayer_service.dart';
import '../widgets/prayer_category_selector.dart';
import '../widgets/prayer_text_display.dart';
import '../widgets/prayer_customization_panel.dart';

/// Prayer generation screen with AI integration
class PrayerGenerationScreen extends ConsumerStatefulWidget {
  const PrayerGenerationScreen({super.key});

  @override
  ConsumerState<PrayerGenerationScreen> createState() =>
      _PrayerGenerationScreenState();
}

class _PrayerGenerationScreenState
    extends ConsumerState<PrayerGenerationScreen> {
  String _selectedCategory = 'gratitude';
  String _selectedTone = 'warm';
  String _selectedLength = 'medium';
  String _customIntention = '';
  bool _isGenerating = false;
  Prayer? _generatedPrayer;

  final TextEditingController _intentionController = TextEditingController();

  @override
  void dispose() {
    _intentionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const GradientText(
          'Generate Prayer',
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE5F0FF)],
          ),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        actions: [
          if (_generatedPrayer != null)
            IconButton(
              onPressed: _savePrayer,
              icon: const Icon(
                Icons.bookmark_outline,
                color: Colors.white,
              ),
              tooltip: 'Save Prayer',
            ),
          if (_generatedPrayer != null)
            IconButton(
              onPressed: _sharePrayer,
              icon: const Icon(
                Icons.share,
                color: Colors.white,
              ),
              tooltip: 'Share Prayer',
            ),
        ],
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: _generatedPrayer == null
              ? _buildGenerationInterface()
              : _buildPrayerDisplay(),
        ),
      ),
    );
  }

  Widget _buildGenerationInterface() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          EnhancedGlassCard(
            borderRadius: 20,
            enableShimmer: true,
            child: Column(
              children: [
                const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'AI-Guided Prayer Generation',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Let AI help you create a personalized prayer for your spiritual needs',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Prayer Category Selection
          Text(
            'Prayer Category',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 12),
          PrayerCategorySelector(
            selectedCategory: _selectedCategory,
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),

          const SizedBox(height: 24),

          // Personal Intention
          Text(
            'Personal Intention (Optional)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 12),
          EnhancedGlassCard(
            padding: EdgeInsets.zero,
            borderRadius: 12,
            enableShimmer: false,
            child: TextField(
              controller: _intentionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText:
                    'Share what\'s on your heart or specific prayers needs...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: (value) {
                setState(() {
                  _customIntention = value;
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // Prayer Customization
          PrayerCustomizationPanel(
            selectedTone: _selectedTone,
            selectedLength: _selectedLength,
            onToneChanged: (tone) {
              setState(() {
                _selectedTone = tone;
              });
            },
            onLengthChanged: (length) {
              setState(() {
                _selectedLength = length;
              });
            },
          ),

          const SizedBox(height: 32),

          // Generate Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isGenerating ? null : _generatePrayer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.healingTeal,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                elevation: 8,
                shadowColor: AppTheme.healingTeal.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isGenerating
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Generating Prayer...',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    )
                  : Text(
                      'Generate Prayer',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPrayerDisplay() {
    return Column(
      children: [
        Expanded(
          child: PrayerTextDisplay(
            prayer: _generatedPrayer!,
            onRegenerate: _regeneratePrayer,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _startOver,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.healingTeal,
                      side: const BorderSide(
                          color: AppTheme.healingTeal, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Start Over',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _savePrayer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.healingTeal,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Save Prayer',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _generatePrayer() async {
    if (_isGenerating) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      final prayer = await ref.read(prayerServiceProvider).generatePrayer(
            category: _selectedCategory,
            tone: _selectedTone,
            length: _selectedLength,
            customIntention:
                _customIntention.trim().isEmpty ? null : _customIntention,
          );

      setState(() {
        _generatedPrayer = prayer;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate prayer: $e'),
            backgroundColor: AppTheme.crisisColor,
          ),
        );
      }
    }
  }

  Future<void> _regeneratePrayer() async {
    await _generatePrayer();
  }

  void _startOver() {
    setState(() {
      _generatedPrayer = null;
      _intentionController.clear();
      _customIntention = '';
    });
  }

  Future<void> _savePrayer() async {
    if (_generatedPrayer == null) return;

    try {
      await ref.read(prayerServiceProvider).savePrayer(_generatedPrayer!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prayer saved successfully!'),
            backgroundColor: AppTheme.healingTeal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save prayer: $e'),
            backgroundColor: AppTheme.crisisColor,
          ),
        );
      }
    }
  }

  void _sharePrayer() {
    if (_generatedPrayer == null) return;

    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing functionality coming soon!'),
        backgroundColor: AppTheme.healingTeal,
      ),
    );
  }
}
