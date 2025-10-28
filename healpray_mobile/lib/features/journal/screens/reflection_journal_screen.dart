import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/adaptive_app_bar.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/app_theme.dart';

/// Journal entry model
class JournalEntry {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final JournalType type;
  final List<String> gratitudeItems;
  final String? spiritualInsight;
  final String? mood;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.type,
    this.gratitudeItems = const [],
    this.spiritualInsight,
    this.mood,
  });
}

enum JournalType {
  daily,
  gratitude,
  spiritual,
  answered,
}

extension JournalTypeExtension on JournalType {
  String get displayName {
    switch (this) {
      case JournalType.daily:
        return 'Daily Reflection';
      case JournalType.gratitude:
        return 'Gratitude';
      case JournalType.spiritual:
        return 'Spiritual Insight';
      case JournalType.answered:
        return 'Answered Prayer';
    }
  }

  IconData get icon {
    switch (this) {
      case JournalType.daily:
        return Icons.book;
      case JournalType.gratitude:
        return Icons.favorite;
      case JournalType.spiritual:
        return Icons.auto_awesome;
      case JournalType.answered:
        return Icons.check_circle;
    }
  }

  List<Color> get colors {
    switch (this) {
      case JournalType.daily:
        return [AppTheme.celestialCyan, AppTheme.sacredBlue];
      case JournalType.gratitude:
        return [AppTheme.sunriseGold, AppTheme.hopeOrange];
      case JournalType.spiritual:
        return [AppTheme.mysticalPurple, AppTheme.sacredBlue];
      case JournalType.answered:
        return [AppTheme.healingTeal, AppTheme.celestialCyan];
    }
  }
}

/// Reflection Journal screen with multiple journal types
class ReflectionJournalScreen extends ConsumerStatefulWidget {
  const ReflectionJournalScreen({super.key});

  @override
  ConsumerState<ReflectionJournalScreen> createState() => _ReflectionJournalScreenState();
}

class _ReflectionJournalScreenState extends ConsumerState<ReflectionJournalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  JournalType _selectedType = JournalType.daily;

  // Sample data
  final List<JournalEntry> _entries = [
    JournalEntry(
      id: '1',
      title: 'A Blessed Day',
      content: 'Today I felt God\'s presence in the morning sunrise. The beauty reminded me of His creative power and love for us.',
      date: DateTime.now(),
      type: JournalType.daily,
      mood: 'Joyful',
      gratitudeItems: ['Morning prayer time', 'Health', 'Family'],
    ),
    JournalEntry(
      id: '2',
      title: 'Three Blessings',
      content: '',
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: JournalType.gratitude,
      gratitudeItems: [
        'A warm home',
        'Supportive friends',
        'Progress in my spiritual journey',
      ],
    ),
    JournalEntry(
      id: '3',
      title: 'Understanding Faith',
      content: 'Realized today that faith isn\'t about having all the answers - it\'s about trusting God even when we don\'t.',
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: JournalType.spiritual,
      spiritualInsight: 'Trust is the foundation of faith',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<JournalEntry> get _filteredEntries {
    return _entries.where((e) => e.type == _selectedType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdaptiveAppBar(
        title: const Text('Reflection Journal'),
      ),
      body: AnimatedGradientBackground(
        child: Column(
          children: [
            // Journal Type Selector
            Container(
              height: 140,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildTypeCard(JournalType.daily),
                  _buildTypeCard(JournalType.gratitude),
                  _buildTypeCard(JournalType.spiritual),
                  _buildTypeCard(JournalType.answered),
                ],
              ),
            ),

            // Entries List
            Expanded(
              child: _filteredEntries.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredEntries.length,
                      itemBuilder: (context, index) {
                        return _buildEntryCard(_filteredEntries[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createEntry(_selectedType),
        icon: Icon(_selectedType.icon),
        label: Text('New ${_selectedType.displayName}'),
        backgroundColor: _selectedType.colors[0],
      ),
    );
  }

  Widget _buildTypeCard(JournalType type) {
    final isSelected = _selectedType == type;
    final count = _entries.where((e) => e.type == type).length;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isSelected ? 140 : 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? type.colors
                : [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.05)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                type.icon,
                color: Colors.white,
                size: isSelected ? 36 : 32,
              ),
              const SizedBox(height: 8),
              Text(
                type.displayName,
                style: TextStyle(
                  fontSize: isSelected ? 13 : 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntryCard(JournalEntry entry) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _viewEntry(entry),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: entry.type.colors),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(entry.type.icon, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, MMM d').format(entry.date),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (entry.mood != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      entry.mood!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            if (entry.content.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                entry.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            if (entry.gratitudeItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.gratitudeItems.take(3).map((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          item,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              if (entry.gratitudeItems.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+${entry.gratitudeItems.length - 3} more',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],

            if (entry.spiritualInsight != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.wisdomGold.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: AppTheme.wisdomGold, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.spiritualInsight!,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.wisdomGold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: _selectedType.colors),
              shape: BoxShape.circle,
            ),
            child: Icon(_selectedType.icon, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            'Start Your ${_selectedType.displayName}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              _getEmptyStateMessage(),
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _getEmptyStateMessage() {
    switch (_selectedType) {
      case JournalType.daily:
        return 'Reflect on your day and document your spiritual journey';
      case JournalType.gratitude:
        return 'Count your blessings and cultivate a thankful heart';
      case JournalType.spiritual:
        return 'Capture insights and revelations from your spiritual growth';
      case JournalType.answered:
        return 'Celebrate answered prayers and God\'s faithfulness';
    }
  }

  void _createEntry(JournalType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => JournalEditorScreen(type: type),
      ),
    );
  }

  void _viewEntry(JournalEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => JournalDetailScreen(entry: entry),
      ),
    );
  }
}

/// Journal Editor Screen
class JournalEditorScreen extends StatefulWidget {
  final JournalType type;
  final JournalEntry? entry;

  const JournalEditorScreen({super.key, required this.type, this.entry});

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _insightController;
  final List<String> _gratitudeItems = [];
  final TextEditingController _gratitudeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController = TextEditingController(text: widget.entry?.content ?? '');
    _insightController = TextEditingController(text: widget.entry?.spiritualInsight ?? '');
    if (widget.entry != null) {
      _gratitudeItems.addAll(widget.entry!.gratitudeItems);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _insightController.dispose();
    _gratitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdaptiveAppBar(
        title: Text(widget.entry == null ? 'New ${widget.type.displayName}' : 'Edit Entry'),
        actions: [
          TextButton(
            onPressed: _saveEntry,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: AnimatedGradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: widget.type.colors),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.type.icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      widget.type.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Title Field
              GlassCard(
                child: TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Give it a title...',
                    hintStyle: TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                ),
              ),

              const SizedBox(height: 16),

              // Gratitude List (for gratitude type)
              if (widget.type == JournalType.gratitude) ...[
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'What are you grateful for?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...(_gratitudeItems.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white70, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _gratitudeItems.removeAt(entry.key);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      })),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _gratitudeController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Add another...',
                                hintStyle: const TextStyle(color: Colors.white60),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.1),
                              ),
                              onSubmitted: (value) {
                                if (value.trim().isNotEmpty) {
                                  setState(() {
                                    _gratitudeItems.add(value.trim());
                                    _gratitudeController.clear();
                                  });
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Colors.white),
                            onPressed: () {
                              if (_gratitudeController.text.trim().isNotEmpty) {
                                setState(() {
                                  _gratitudeItems.add(_gratitudeController.text.trim());
                                  _gratitudeController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Content Field
              GlassCard(
                child: TextField(
                  controller: _contentController,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.type == JournalType.gratitude
                        ? 'Add additional thoughts (optional)...'
                        : 'Write your reflection...',
                    hintStyle: const TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  minLines: 8,
                ),
              ),

              // Spiritual Insight Field (for spiritual type)
              if (widget.type == JournalType.spiritual) ...[
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: AppTheme.wisdomGold, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Key Insight',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _insightController,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppTheme.wisdomGold,
                          fontStyle: FontStyle.italic,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Summarize the main insight...',
                          hintStyle: TextStyle(color: Colors.white60),
                          border: InputBorder.none,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _saveEntry() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a title'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (widget.type == JournalType.gratitude && _gratitudeItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one thing you\'re grateful for'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // TODO: Save to database
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.entry == null ? 'Entry saved' : 'Entry updated'),
        backgroundColor: widget.type.colors[0],
      ),
    );
  }
}

/// Journal Detail Screen
class JournalDetailScreen extends StatelessWidget {
  final JournalEntry entry;

  const JournalDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdaptiveAppBar(
        title: Text(entry.type.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => JournalEditorScreen(type: entry.type, entry: entry),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: AnimatedGradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: entry.type.colors),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(entry.type.icon, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        entry.type.displayName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  entry.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                // Date and Mood
                Row(
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(entry.date),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    if (entry.mood != null) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          entry.mood!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                if (entry.gratitudeItems.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white30),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.white, size: 22),
                      SizedBox(width: 12),
                      Text(
                        'Grateful For',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...entry.gratitudeItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white70, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                if (entry.content.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white30),
                  const SizedBox(height: 16),
                  Text(
                    entry.content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.8,
                    ),
                  ),
                ],

                if (entry.spiritualInsight != null) ...[
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white30),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.wisdomGold.withValues(alpha: 0.2),
                          AppTheme.wisdomGold.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.wisdomGold.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb, color: AppTheme.wisdomGold, size: 24),
                            const SizedBox(width: 12),
                            const Text(
                              'Key Insight',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          entry.spiritualInsight!,
                          style: TextStyle(
                            fontSize: 17,
                            color: AppTheme.wisdomGold,
                            fontStyle: FontStyle.italic,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
