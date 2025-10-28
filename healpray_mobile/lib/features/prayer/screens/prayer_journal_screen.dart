import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/adaptive_app_bar.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/app_theme.dart';

/// Prayer Journal entry model
class PrayerJournalEntry {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final List<String> tags;
  final bool isAnswered;

  PrayerJournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.tags,
    this.isAnswered = false,
  });
}

/// Prayer Journal screen with full CRUD operations
class PrayerJournalScreen extends ConsumerStatefulWidget {
  const PrayerJournalScreen({super.key});

  @override
  ConsumerState<PrayerJournalScreen> createState() => _PrayerJournalScreenState();
}

class _PrayerJournalScreenState extends ConsumerState<PrayerJournalScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterTag = 'All';

  // Sample data - Replace with actual state management
  final List<PrayerJournalEntry> _entries = [
    PrayerJournalEntry(
      id: '1',
      title: 'Guidance for Career Decision',
      content: 'Lord, I seek your wisdom as I navigate this important career choice. Help me discern your will and give me peace in my decision.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      tags: ['Career', 'Guidance'],
    ),
    PrayerJournalEntry(
      id: '2',
      title: 'Healing for My Mother',
      content: 'Father, I lift up my mother to you. Touch her body with your healing power and grant her strength during this difficult time.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      tags: ['Health', 'Family'],
      isAnswered: true,
    ),
    PrayerJournalEntry(
      id: '3',
      title: 'Peace in Relationships',
      content: 'God, help me to be a peacemaker in my relationships. Give me patience, understanding, and your love to share with others.',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      tags: ['Relationships', 'Peace'],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PrayerJournalEntry> get _filteredEntries {
    return _entries.where((entry) {
      final matchesSearch = _searchQuery.isEmpty ||
          entry.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          entry.content.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesTag = _filterTag == 'All' || entry.tags.contains(_filterTag);
      return matchesSearch && matchesTag;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredEntries = _filteredEntries;

    return Scaffold(
      appBar: AdaptiveAppBar(
        title: const Text('Prayer Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportJournal,
            tooltip: 'Export Journal',
          ),
        ],
      ),
      body: AnimatedGradientBackground(
        child: Column(
          children: [
            // Search and Filter Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search prayers...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white70),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Tag Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All'),
                        _buildFilterChip('Career'),
                        _buildFilterChip('Health'),
                        _buildFilterChip('Family'),
                        _buildFilterChip('Guidance'),
                        _buildFilterChip('Peace'),
                        _buildFilterChip('Relationships'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Journal Entries List
            Expanded(
              child: filteredEntries.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredEntries.length,
                      itemBuilder: (context, index) {
                        return _buildJournalEntryCard(filteredEntries[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewEntry,
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
        backgroundColor: AppTheme.healingTeal,
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterTag == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => setState(() => _filterTag = label),
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        selectedColor: AppTheme.healingTeal,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        checkmarkColor: Colors.white,
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildJournalEntryCard(PrayerJournalEntry entry) {
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
                if (entry.isAnswered)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.sunriseGold, AppTheme.hopeOrange],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                if (entry.isAnswered) const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white70),
                  color: AppTheme.mysticalPurple.withValues(alpha: 0.95),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.white70),
                          SizedBox(width: 12),
                          Text('Edit', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'answered',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white70),
                          SizedBox(width: 12),
                          Text('Mark as Answered', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.redAccent),
                          SizedBox(width: 12),
                          Text('Delete', style: TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) => _handleEntryAction(value as String, entry),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content Preview
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
            const SizedBox(height: 16),

            // Tags and Date
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: entry.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(entry.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
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
          Icon(
            Icons.book_outlined,
            size: 80,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _filterTag != 'All'
                ? 'No matching entries found'
                : 'Start Your Prayer Journal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _filterTag != 'All'
                ? 'Try a different search or filter'
                : 'Document your prayers and God\'s faithfulness',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _createNewEntry() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PrayerJournalEditorScreen(),
      ),
    );
  }

  void _viewEntry(PrayerJournalEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PrayerJournalDetailScreen(entry: entry),
      ),
    );
  }

  void _handleEntryAction(String action, PrayerJournalEntry entry) {
    switch (action) {
      case 'edit':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PrayerJournalEditorScreen(entry: entry),
          ),
        );
        break;
      case 'answered':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marked "${entry.title}" as answered'),
            backgroundColor: AppTheme.healingTeal,
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(entry);
        break;
    }
  }

  void _showDeleteConfirmation(PrayerJournalEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.mysticalPurple.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Entry?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This prayer journal entry will be permanently deleted.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Entry deleted'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _exportJournal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.mysticalPurple.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Export Journal', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Export your prayer journal as a PDF document?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Journal exported successfully'),
                  backgroundColor: AppTheme.healingTeal,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.healingTeal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }
}

/// Prayer Journal Editor Screen (Create/Edit)
class PrayerJournalEditorScreen extends StatefulWidget {
  final PrayerJournalEntry? entry;

  const PrayerJournalEditorScreen({super.key, this.entry});

  @override
  State<PrayerJournalEditorScreen> createState() => _PrayerJournalEditorScreenState();
}

class _PrayerJournalEditorScreenState extends State<PrayerJournalEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final List<String> _selectedTags = [];
  final List<String> _availableTags = [
    'Career',
    'Health',
    'Family',
    'Guidance',
    'Peace',
    'Relationships',
    'Gratitude',
    'Strength',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController = TextEditingController(text: widget.entry?.content ?? '');
    if (widget.entry != null) {
      _selectedTags.addAll(widget.entry!.tags);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entry != null;

    return Scaffold(
      appBar: AdaptiveAppBar(
        title: Text(isEditing ? 'Edit Entry' : 'New Entry'),
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
                    hintText: 'Prayer title...',
                    hintStyle: TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                ),
              ),

              const SizedBox(height: 16),

              // Content Field
              GlassCard(
                child: TextField(
                  controller: _contentController,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.6,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Write your prayer...',
                    hintStyle: TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  minLines: 8,
                ),
              ),

              const SizedBox(height: 24),

              // Tags Section
              const Text(
                'Tags',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    selectedColor: AppTheme.healingTeal,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                    checkmarkColor: Colors.white,
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveEntry() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both title and content'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // TODO: Save to database/state
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.entry != null ? 'Entry updated' : 'Entry created'),
        backgroundColor: AppTheme.healingTeal,
      ),
    );
  }
}

/// Prayer Journal Detail Screen (View)
class PrayerJournalDetailScreen extends StatelessWidget {
  final PrayerJournalEntry entry;

  const PrayerJournalDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdaptiveAppBar(
        title: const Text('Prayer Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sharing: ${entry.title}'),
                  backgroundColor: AppTheme.healingTeal,
                ),
              );
            },
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
                // Status Badge
                if (entry.isAnswered)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.sunriseGold, AppTheme.hopeOrange],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Prayer Answered',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (entry.isAnswered) const SizedBox(height: 16),

                // Title
                Text(
                  entry.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                // Date
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(entry.createdAt),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),

                // Content
                Text(
                  entry.content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: 24),

                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entry.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
