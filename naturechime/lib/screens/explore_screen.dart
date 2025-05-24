import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naturechime/models/recording_model.dart';
import 'package:naturechime/widgets/recording_list_item.dart';

// Mock data now uses the Recording model
// Note: audioUrl is part of the model but not directly used in this list item's display logic yet.
final List<Recording> _mockRecordings = [
  Recording(
    id: '1',
    title: 'Morning Forest Birds',
    location: 'Blackwood Forest',
    username: 'NatureFan1',
    createdAt: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5, hours: 2))),
    durationSeconds: 185,
    notes: 'Clear bird songs, a bit of wind noise.',
    userId: 'user123',
    audioUrl: 'https://example.com/audio1.mp3',
  ),
  Recording(
    id: '2',
    title: 'Ocean Waves at Sunset',
    location: 'Sunset Beach',
    username: 'BeachLover',
    createdAt: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 10, hours: 18))),
    durationSeconds: 300,
    notes: 'Calm waves, distant seagulls.',
    userId: 'user456',
    audioUrl: 'https://example.com/audio2.mp3',
  ),
  Recording(
    id: '3',
    title: 'Rain on Tent',
    location: 'Mountain Camp',
    username: 'HikerDude',
    createdAt: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2, hours: 22))),
    durationSeconds: 600,
    userId: 'user123', // This recording belongs to 'user123'
    notes: null, // Example of no notes
    audioUrl: 'https://example.com/audio3.mp3',
  ),
  Recording(
    id: '4',
    title: 'City Park Ambience',
    location: 'Central Park',
    username: 'UrbanExplorer',
    createdAt: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1, hours: 12))),
    durationSeconds: 240,
    notes: 'Distant city sounds, children playing.',
    userId: 'user789',
    audioUrl: 'https://example.com/audio4.mp3',
  ),
];

// Assume current logged-in user ID
const String currentUserId = 'user123';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Recording> _filteredRecordings = _mockRecordings; // Use Recording model
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterRecordings);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterRecordings);
    _searchController.dispose();
    super.dispose();
  }

  void _filterRecordings() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRecordings = _mockRecordings.where((recording) {
        final titleMatch = recording.title.toLowerCase().contains(query);
        // Ensure location is not null before calling toLowerCase()
        final locationMatch = recording.location?.toLowerCase().contains(query) ?? false;
        return titleMatch || locationMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 18.0, 16.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Sounds',
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by title or location',
              prefixIcon: Icon(
                CupertinoIcons.search,
                color: colorScheme.onSurfaceVariant,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
            ),
            style: TextStyle(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _filteredRecordings.isEmpty
                ? Center(
                    child: Text(
                      'No recordings found matching your search.',
                      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8.0),
                    itemCount: _filteredRecordings.length,
                    itemBuilder: (context, index) {
                      final recording = _filteredRecordings[index];
                      return RecordingListItem(
                        key: ValueKey(recording.id),
                        title: recording.title,
                        // Convert Timestamp to DateTime for the UI widget
                        dateTime: recording.createdAt.toDate(),
                        durationSeconds: recording.durationSeconds,
                        location: recording.location,
                        // username is now part of the Recording model
                        username: recording.username ?? 'Unknown User', // Provide a fallback
                        notes: recording.notes,
                        userId: recording.userId,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
