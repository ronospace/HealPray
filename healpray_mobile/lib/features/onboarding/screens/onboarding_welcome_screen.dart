import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/widgets/spiritual_background.dart';

/// Welcome screen for onboarding flow
class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SpiritualBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                
                // Header
                _buildHeader(context),
                
                const Spacer(),
                
                // Content
                _buildContent(context),
                
                const Spacer(),
                
                // Continue button
                _buildContinueButton(context),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Logo with glow effect
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.healingTeal.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.favorite,
            size: 50,
            color: AppTheme.healingTeal,
          ),
        ),
        
        const SizedBox(height: 24),
        
        Text(
          'Welcome to HealPray',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        // Main message
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Your Spiritual Journey Begins',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Let us personalize your experience to support your unique path of healing, prayer, and spiritual growth.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Features preview
        Row(
          children: [
            Expanded(
              child: _buildFeatureItem(
                context,
                Icons.psychology,
                'AI Prayer\nGeneration',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFeatureItem(
                context,
                Icons.favorite_border,
                'Mood\nTracking',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFeatureItem(
                context,
                Icons.chat_bubble_outline,
                'Spiritual\nGuidance',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.sunriseGold,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Column(
      children: [
        // Main continue button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => context.push('/onboarding/spiritual-preferences'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.sunriseGold,
              foregroundColor: AppTheme.midnightBlue,
              elevation: 8,
              shadowColor: AppTheme.sunriseGold.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(27),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Begin Your Journey',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.midnightBlue,
                    fontWeight: FontWeight.w700,
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
        
        const SizedBox(height: 16),
        
        // Skip option
        TextButton(
          onPressed: () => context.go('/'),
          child: Text(
            'Skip for now',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.7),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
