import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';

/// Emergency contact card with call/text functionality
class EmergencyContactCard extends StatelessWidget {
  final String name;
  final String phoneNumber;
  final String description;
  final bool isEmergency;
  final bool isTextLine;

  const EmergencyContactCard({
    super.key,
    required this.name,
    required this.phoneNumber,
    required this.description,
    this.isEmergency = false,
    this.isTextLine = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isEmergency ? Colors.red[50] : Colors.blue[50];
    final borderColor = isEmergency ? Colors.red[200] : Colors.blue[200];
    final buttonColor = isEmergency ? Colors.red[600] : Colors.blue[600];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: buttonColor?.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isEmergency ? Icons.emergency : Icons.support_agent,
                  color: buttonColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.midnightBlue,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phoneNumber,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: buttonColor,
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _makeCall(phoneNumber),
                  icon: Icon(isTextLine ? Icons.message : Icons.phone),
                  label: Text(
                      isTextLine ? 'Text $phoneNumber' : 'Call $phoneNumber'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _copyToClipboard(context, phoneNumber),
                icon: const Icon(Icons.copy),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.grey[700],
                ),
                tooltip: 'Copy number',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _makeCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$text copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.healingTeal,
      ),
    );
  }
}
