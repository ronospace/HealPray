import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../models/simple_mood_entry.dart';
import '../services/mood_service.dart';
import '../utils/mood_export.dart';

/// Screen for exporting mood data in various formats
class MoodExportScreen extends ConsumerStatefulWidget {
  const MoodExportScreen({super.key});

  @override
  ConsumerState<MoodExportScreen> createState() => _MoodExportScreenState();
}

class _MoodExportScreenState extends ConsumerState<MoodExportScreen> {
  final MoodService _moodService = MoodService.instance;

  TimePeriod _selectedPeriod = TimePeriod.last30Days;
  ExportFormat _selectedFormat = ExportFormat.json;
  bool _includeAnalytics = true;
  bool _includeMetadata = true;
  bool _isExporting = false;

  List<SimpleMoodEntry> _entries = [];
  int _entryCount = 0;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final allEntries = _moodService.getAllMoodEntries();
    setState(() {
      _entries = _filterEntriesByPeriod(allEntries);
      _entryCount = _entries.length;
    });
  }

  List<SimpleMoodEntry> _filterEntriesByPeriod(List<SimpleMoodEntry> entries) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case TimePeriod.thisWeek:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case TimePeriod.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case TimePeriod.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        startDate = lastMonth;
        final endDate = DateTime(now.year, now.month, 0);
        return entries
            .where((entry) =>
                entry.timestamp
                    .isAfter(startDate.subtract(const Duration(seconds: 1))) &&
                entry.timestamp
                    .isBefore(endDate.add(const Duration(seconds: 1))))
            .toList();
      case TimePeriod.last30Days:
        startDate = now.subtract(const Duration(days: 30));
        break;
      case TimePeriod.last90Days:
        startDate = now.subtract(const Duration(days: 90));
        break;
      case TimePeriod.thisYear:
        startDate = DateTime(now.year, 1, 1);
        break;
    }

    return entries
        .where((entry) => entry.timestamp.isAfter(startDate))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Export Mood Data',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDataSummary(),
            const SizedBox(height: 24),
            _buildTimePeriodSelector(),
            const SizedBox(height: 24),
            _buildFormatSelector(),
            const SizedBox(height: 24),
            _buildOptionsSelector(),
            const SizedBox(height: 32),
            _buildExportButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.morningGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.healingTeal.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Export Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Entries',
                  _entryCount.toString(),
                  Icons.calendar_today,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Period',
                  _getPeriodDisplayName(_selectedPeriod),
                  Icons.date_range,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Format',
                  _selectedFormat.name.toUpperCase(),
                  Icons.file_download,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Size',
                  _getEstimatedSize(),
                  Icons.storage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePeriodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time Period',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: TimePeriod.values.map((period) {
              final isSelected = period == _selectedPeriod;
              return ListTile(
                title: Text(
                  _getPeriodDisplayName(period),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppTheme.healingTeal
                        : AppTheme.textPrimary,
                  ),
                ),
                subtitle: Text(_getPeriodDescription(period)),
                leading: Radio<TimePeriod>(
                  value: period,
                  groupValue: _selectedPeriod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriod = value!;
                    });
                    _loadEntries();
                  },
                  activeColor: AppTheme.healingTeal,
                ),
                onTap: () {
                  setState(() {
                    _selectedPeriod = period;
                  });
                  _loadEntries();
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFormatSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Export Format',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildFormatOption(
                ExportFormat.json,
                'JSON Format',
                'Complete data with analytics',
                Icons.code,
              ),
              const Divider(height: 1),
              _buildFormatOption(
                ExportFormat.csv,
                'CSV Spreadsheet',
                'For Excel or Google Sheets',
                Icons.table_chart,
              ),
              const Divider(height: 1),
              _buildFormatOption(
                ExportFormat.report,
                'Analytics Report',
                'Human-readable insights report',
                Icons.analytics,
              ),
              const Divider(height: 1),
              _buildFormatOption(
                ExportFormat.all,
                'Complete Package',
                'All formats in one export',
                Icons.folder_zip,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormatOption(
      ExportFormat format, String title, String subtitle, IconData icon) {
    final isSelected = format == _selectedFormat;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.healingTeal : AppTheme.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppTheme.healingTeal : AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: Radio<ExportFormat>(
        value: format,
        groupValue: _selectedFormat,
        onChanged: (value) {
          setState(() {
            _selectedFormat = value!;
          });
        },
        activeColor: AppTheme.healingTeal,
      ),
      onTap: () {
        setState(() {
          _selectedFormat = format;
        });
      },
    );
  }

  Widget _buildOptionsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Export Options',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text(
                  'Include Analytics',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                subtitle: const Text('Add insights, patterns, and statistics'),
                value: _includeAnalytics,
                onChanged: (value) {
                  setState(() {
                    _includeAnalytics = value;
                  });
                },
                activeThumbColor: AppTheme.healingTeal,
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text(
                  'Include Metadata',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                subtitle:
                    const Text('Add triggers, activities, and extra details'),
                value: _includeMetadata,
                onChanged: (value) {
                  setState(() {
                    _includeMetadata = value;
                  });
                },
                activeThumbColor: AppTheme.healingTeal,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isExporting || _entryCount == 0 ? null : _exportData,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.healingTeal,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: AppTheme.healingTeal.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isExporting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Exporting...'),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.download, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _entryCount == 0
                        ? 'No Data to Export'
                        : 'Export $_entryCount Entries',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _exportData() async {
    if (_entries.isEmpty) return;

    setState(() {
      _isExporting = true;
    });

    try {
      String exportContent;
      String fileName;

      switch (_selectedFormat) {
        case ExportFormat.json:
          exportContent = MoodExporter.exportToJson(
            entries: _entries,
            includeAnalytics: _includeAnalytics,
          );
          fileName = 'mood_data_${_getPeriodFilePrefix(_selectedPeriod)}.json';
          break;
        case ExportFormat.csv:
          exportContent = MoodExporter.exportToCSV(
            entries: _entries,
            includeMetadata: _includeMetadata,
          );
          fileName = 'mood_data_${_getPeriodFilePrefix(_selectedPeriod)}.csv';
          break;
        case ExportFormat.report:
          exportContent = MoodExporter.exportAnalyticsReport(
            entries: _entries,
          );
          fileName = 'mood_report_${_getPeriodFilePrefix(_selectedPeriod)}.txt';
          break;
        case ExportFormat.all:
          final package = MoodExporter.createExportPackage(entries: _entries);
          // For now, just export JSON as a fallback
          exportContent = package['mood_data.json']!;
          fileName =
              'mood_data_complete_${_getPeriodFilePrefix(_selectedPeriod)}.json';
          break;
      }

      // Use share_plus to share the file
      await Share.share(
        exportContent,
        subject: 'HealPray Mood Data Export',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data exported successfully! 📊'),
            backgroundColor: AppTheme.healingTeal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  String _getPeriodDisplayName(TimePeriod period) {
    switch (period) {
      case TimePeriod.thisWeek:
        return 'This Week';
      case TimePeriod.thisMonth:
        return 'This Month';
      case TimePeriod.lastMonth:
        return 'Last Month';
      case TimePeriod.last30Days:
        return 'Last 30 Days';
      case TimePeriod.last90Days:
        return 'Last 90 Days';
      case TimePeriod.thisYear:
        return 'This Year';
    }
  }

  String _getPeriodDescription(TimePeriod period) {
    final now = DateTime.now();
    switch (period) {
      case TimePeriod.thisWeek:
        return 'Monday to Sunday this week';
      case TimePeriod.thisMonth:
        return 'All entries from this month';
      case TimePeriod.lastMonth:
        return 'All entries from last month';
      case TimePeriod.last30Days:
        return 'Rolling 30-day period';
      case TimePeriod.last90Days:
        return 'Rolling 90-day period';
      case TimePeriod.thisYear:
        return 'January 1st to today';
    }
  }

  String _getPeriodFilePrefix(TimePeriod period) {
    final now = DateTime.now();
    switch (period) {
      case TimePeriod.thisWeek:
        return 'this_week';
      case TimePeriod.thisMonth:
        return '${now.year}_${now.month.toString().padLeft(2, '0')}';
      case TimePeriod.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1);
        return '${lastMonth.year}_${lastMonth.month.toString().padLeft(2, '0')}';
      case TimePeriod.last30Days:
        return 'last_30_days';
      case TimePeriod.last90Days:
        return 'last_90_days';
      case TimePeriod.thisYear:
        return '${now.year}';
    }
  }

  String _getEstimatedSize() {
    if (_entries.isEmpty) return '0 KB';

    // Rough estimation based on entry count
    final baseSize = _entries.length * 0.5; // ~0.5KB per entry

    switch (_selectedFormat) {
      case ExportFormat.json:
        return '${(baseSize * 1.5).toStringAsFixed(0)} KB';
      case ExportFormat.csv:
        return '${(baseSize * 0.8).toStringAsFixed(0)} KB';
      case ExportFormat.report:
        return '${(baseSize * 1.2).toStringAsFixed(0)} KB';
      case ExportFormat.all:
        return '${(baseSize * 3.5).toStringAsFixed(0)} KB';
    }
  }
}
