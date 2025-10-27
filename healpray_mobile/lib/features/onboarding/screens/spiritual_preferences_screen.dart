import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger.dart';
import '../../auth/widgets/spiritual_background.dart';
import '../widgets/onboarding_progress.dart';
import '../widgets/preference_card.dart';

/// Spiritual preferences setup screen
class SpiritualPreferencesScreen extends ConsumerStatefulWidget {
  const SpiritualPreferencesScreen({super.key});

  @override
  ConsumerState<SpiritualPreferencesScreen> createState() =>
      _SpiritualPreferencesScreenState();
}

class _SpiritualPreferencesScreenState
    extends ConsumerState<SpiritualPreferencesScreen> {
  String? _selectedDenomination;
  String _selectedLanguage = 'en';
  String _selectedTone = 'warm';
  String _selectedLength = 'medium';

  final List<Map<String, dynamic>> _denominations = [
    {'value': 'christian', 'label': 'Christian', 'icon': Icons.church},
    {'value': 'catholic', 'label': 'Catholic', 'icon': Icons.account_balance},
    {'value': 'protestant', 'label': 'Protestant', 'icon': Icons.brightness_7},
    {'value': 'muslim', 'label': 'Muslim', 'icon': Icons.mosque},
    {'value': 'jewish', 'label': 'Jewish', 'icon': Icons.star},
    {'value': 'hindu', 'label': 'Hindu', 'icon': Icons.self_improvement},
    {'value': 'buddhist', 'label': 'Buddhist', 'icon': Icons.spa},
    {
      'value': 'spiritual',
      'label': 'Spiritual (Non-religious)',
      'icon': Icons.nature_people
    },
    {'value': 'other', 'label': 'Other', 'icon': Icons.more_horiz},
    {
      'value': 'none',
      'label': 'Prefer not to specify',
      'icon': Icons.help_outline
    },
  ];

  final List<Map<String, String>> _languages = [
    {'value': 'en', 'label': 'English'},
    {'value': 'es', 'label': 'Spanish'},
    {'value': 'pt', 'label': 'Portuguese'},
    {'value': 'fr', 'label': 'French'},
    {'value': 'hi', 'label': 'Hindi'},
    {'value': 'sw', 'label': 'Swahili'},
  ];

  final List<Map<String, String>> _tones = [
    {'value': 'warm', 'label': 'Warm & Comforting'},
    {'value': 'peaceful', 'label': 'Peaceful & Calm'},
    {'value': 'uplifting', 'label': 'Uplifting & Joyful'},
    {'value': 'contemplative', 'label': 'Contemplative & Deep'},
    {'value': 'gentle', 'label': 'Gentle & Nurturing'},
  ];

  final List<Map<String, String>> _lengths = [
    {'value': 'short', 'label': 'Short (1-2 minutes)'},
    {'value': 'medium', 'label': 'Medium (3-5 minutes)'},
    {'value': 'long', 'label': 'Long (5+ minutes)'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SpiritualBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Progress and header
              _buildHeader(context),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Denomination selection
                      _buildDenominationSection(),

                      const SizedBox(height: 32),

                      // Language selection
                      _buildLanguageSection(),

                      const SizedBox(height: 32),

                      // Prayer tone selection
                      _buildToneSection(),

                      const SizedBox(height: 32),

                      // Prayer length selection
                      _buildLengthSection(),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Continue button
              _buildContinueButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Progress indicator
          const OnboardingProgress(currentStep: 1, totalSteps: 3),

          const SizedBox(height: 24),

          Text(
            'Spiritual Preferences',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 8),

          Text(
            'Help us personalize your spiritual experience',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDenominationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Spiritual Background'),
        const SizedBox(height: 16),
        Text(
          'This helps us provide appropriate prayers and guidance. All beliefs are welcome and respected.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _denominations.map((denomination) {
            final isSelected = _selectedDenomination == denomination['value'];

            return PreferenceCard(
              label: denomination['label'],
              icon: denomination['icon'],
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedDenomination = denomination['value'];
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLanguageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Preferred Language'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _languages.map((language) {
            final isSelected = _selectedLanguage == language['value'];

            return PreferenceCard(
              label: language['label']!,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedLanguage = language['value']!;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildToneSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Prayer Tone'),
        const SizedBox(height: 16),
        Column(
          children: _tones.map((tone) {
            final isSelected = _selectedTone == tone['value'];

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: PreferenceCard(
                label: tone['label']!,
                isSelected: isSelected,
                fullWidth: true,
                onTap: () {
                  setState(() {
                    _selectedTone = tone['value']!;
                  });
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLengthSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Prayer Length'),
        const SizedBox(height: 16),
        Column(
          children: _lengths.map((length) {
            final isSelected = _selectedLength == length['value'];

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: PreferenceCard(
                label: length['label']!,
                isSelected: isSelected,
                fullWidth: true,
                onTap: () {
                  setState(() {
                    _selectedLength = length['value']!;
                  });
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Back button
          OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(60, 54),
            ),
            child: const Icon(Icons.arrow_back),
          ),

          const SizedBox(width: 16),

          // Continue button
          Expanded(
            child: ElevatedButton(
              onPressed: _selectedDenomination != null
                  ? () {
                      // Save preferences and continue
                      _savePreferences();
                      context.push('/onboarding/notification-preferences');
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.sunriseGold,
                foregroundColor: AppTheme.midnightBlue,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.3),
                elevation: 8,
                shadowColor: AppTheme.sunriseGold.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 54),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.midnightBlue,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppTheme.midnightBlue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _savePreferences() {
    // Save spiritual preferences to user profile
    // When Firebase is enabled, this will update Firestore user document:
    // await ref.read(authProvider.notifier).updatePreferences(
    //   UserPreferences(
    //     spiritual: SpiritualPreferences(
    //       denomination: _selectedDenomination,
    //       language: _selectedLanguage,
    //       tone: _selectedTone,
    //       length: _selectedLength,
    //     ),
    //   ),
    // );

    // Currently logs preferences (development mode)
    AppLogger.info('Saving spiritual preferences:');
    AppLogger.info('Denomination: $_selectedDenomination');
    AppLogger.info('Language: $_selectedLanguage');
    AppLogger.info('Tone: $_selectedTone');
    AppLogger.info('Length: $_selectedLength');
  }
}
