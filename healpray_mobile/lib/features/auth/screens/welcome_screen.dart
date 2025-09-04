import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/auth_provider.dart';
import '../widgets/social_auth_button.dart';
import '../widgets/spiritual_background.dart';
import '../../../core/theme/app_theme.dart';

/// Welcome screen with authentication options
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      body: SpiritualBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                
                // Logo and branding
                _buildHeader(context),
                
                const Spacer(),
                
                // Authentication options
                _buildAuthOptions(context, ref),
                
                const SizedBox(height: 32),
                
                // Terms and privacy
                _buildLegalText(context),
                
                const SizedBox(height: 24),
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
        // App logo/icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
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
            size: 60,
            color: AppTheme.healingTeal,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // App name
        Text(
          'HealPray',
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
        
        const SizedBox(height: 12),
        
        // Tagline
        Text(
          'Your Daily Healing & Prayer Companion',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        // Spiritual quote
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            '"Be still and know that I am God" - Psalm 46:10',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthOptions(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Social authentication buttons
        SocialAuthButton(
          icon: Icons.email,
          label: 'Continue with Email',
          onPressed: () => context.push('/auth/login'),
          backgroundColor: AppTheme.healingTeal,
          textColor: Colors.white,
        ),
        
        const SizedBox(height: 16),
        
        SocialAuthButton(
          icon: Icons.g_mobiledata,
          label: 'Continue with Google',
          onPressed: () => _handleGoogleSignIn(ref),
          backgroundColor: Colors.white,
          textColor: Colors.black87,
        ),
        
        const SizedBox(height: 16),
        
        if (Theme.of(context).platform == TargetPlatform.iOS)
          Column(
            children: [
              SocialAuthButton(
                icon: Icons.apple,
                label: 'Continue with Apple',
                onPressed: () => _handleAppleSignIn(ref),
                backgroundColor: Colors.black,
                textColor: Colors.white,
              ),
              const SizedBox(height: 16),
            ],
          ),
        
        // Anonymous/guest option
        TextButton(
          onPressed: () => _handleGuestSignIn(ref),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            'Continue as Guest',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Sign up option
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            TextButton(
              onPressed: () => context.push('/auth/register'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Sign Up',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.sunriseGold,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegalText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'By continuing, you agree to our ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
          children: [
            TextSpan(
              text: 'Terms of Service',
              style: TextStyle(
                color: AppTheme.sunriseGold.withOpacity(0.8),
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(
                color: AppTheme.sunriseGold.withOpacity(0.8),
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn(WidgetRef ref) async {
    await ref.read(authProvider.notifier).signInWithGoogle();
  }

  Future<void> _handleAppleSignIn(WidgetRef ref) async {
    await ref.read(authProvider.notifier).signInWithApple();
  }

  Future<void> _handleGuestSignIn(WidgetRef ref) async {
    await ref.read(authProvider.notifier).signInAnonymously();
  }
}
