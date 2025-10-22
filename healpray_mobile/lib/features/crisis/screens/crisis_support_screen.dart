import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/emergency_contact_card.dart';
import '../widgets/crisis_resource_card.dart';
import '../widgets/immediate_help_section.dart';

/// Crisis support screen with emergency contacts and resources
class CrisisSupportScreen extends StatelessWidget {
  const CrisisSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Crisis support app bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.red[600],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.red[700]!,
                      Colors.red[600]!,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Crisis Support',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You\'re not alone. Help is available.',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main content
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Immediate help section
                const ImmediateHelpSection(),
                const SizedBox(height: 24),

                // Emergency contacts
                _buildSectionHeader(
                  context,
                  'Emergency Contacts',
                  'Available 24/7 for immediate assistance',
                ),
                const SizedBox(height: 16),

                EmergencyContactCard(
                  name: 'National Suicide Prevention Lifeline',
                  phoneNumber: '988',
                  description:
                      'Free, confidential support for people in distress',
                  isEmergency: true,
                ),
                const SizedBox(height: 12),

                EmergencyContactCard(
                  name: 'Crisis Text Line',
                  phoneNumber: '741741',
                  description: 'Text HOME for 24/7 crisis support',
                  isTextLine: true,
                ),
                const SizedBox(height: 12),

                EmergencyContactCard(
                  name: 'Emergency Services',
                  phoneNumber: '911',
                  description: 'For life-threatening emergencies',
                  isEmergency: true,
                ),

                const SizedBox(height: 32),

                // Crisis resources
                _buildSectionHeader(
                  context,
                  'Crisis Resources',
                  'Additional support and information',
                ),
                const SizedBox(height: 16),

                CrisisResourceCard(
                  title: 'Mental Health First Aid',
                  description:
                      'Learn to recognize signs of mental health crisis',
                  icon: Icons.health_and_safety,
                  color: AppTheme.healingTeal,
                  onTap: () =>
                      _launchUrl('https://www.mentalhealthfirstaid.org/'),
                ),
                const SizedBox(height: 12),

                CrisisResourceCard(
                  title: 'NAMI Support Groups',
                  description: 'Find local support groups and resources',
                  icon: Icons.groups,
                  color: Colors.blue[600]!,
                  onTap: () =>
                      _launchUrl('https://www.nami.org/Support-Education'),
                ),
                const SizedBox(height: 12),

                CrisisResourceCard(
                  title: 'Crisis Chat Support',
                  description: 'Online chat with trained counselors',
                  icon: Icons.chat_bubble_outline,
                  color: Colors.green[600]!,
                  onTap: () =>
                      _launchUrl('https://suicidepreventionlifeline.org/chat/'),
                ),
                const SizedBox(height: 12),

                CrisisResourceCard(
                  title: 'Mental Health Resources',
                  description: 'Comprehensive mental health information',
                  icon: Icons.psychology,
                  color: Colors.purple[600]!,
                  onTap: () => _launchUrl(
                      'https://www.mentalhealth.gov/get-help/immediate-help'),
                ),

                const SizedBox(height: 32),

                // Self-care section
                _buildSelfCareSection(context),

                const SizedBox(height: 32),

                // Return to app section
                _buildReturnSection(context),

                const SizedBox(height: 100), // Bottom padding
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.midnightBlue,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildSelfCareSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.sunriseGold.withValues(alpha: 0.1),
            AppTheme.healingTeal.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.sunriseGold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.self_improvement,
                color: AppTheme.healingTeal,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Self-Care Right Now',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.midnightBlue,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'While you seek help, here are some things you can do:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.midnightBlue,
                ),
          ),
          const SizedBox(height: 12),
          _buildSelfCareTip(context, '🌬️', 'Take slow, deep breaths'),
          _buildSelfCareTip(context, '💧', 'Drink some water'),
          _buildSelfCareTip(context, '🤝', 'Reach out to a trusted friend'),
          _buildSelfCareTip(context, '🙏', 'Try a brief prayer or meditation'),
          _buildSelfCareTip(context, '🏠', 'Find a safe, comfortable space'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/meditation'),
                  icon: const Icon(Icons.self_improvement),
                  label: const Text('Guided Meditation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.healingTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/prayer'),
                  icon: const Icon(Icons.favorite),
                  label: const Text('Prayer Support'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.sunriseGold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelfCareTip(BuildContext context, String emoji, String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.midnightBlue,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite,
            color: AppTheme.healingTeal,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            'Remember',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.midnightBlue,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'You are valued, you are loved, and your life has meaning. Crisis is temporary, but recovery is possible.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.healingTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Return to HealPray',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
