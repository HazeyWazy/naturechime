import 'package:flutter/material.dart';
import 'package:naturechime/widgets/recording_list_item.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  // Sample data
  final List<Map<String, dynamic>> _recordings = [
    {
      'title': 'Morning Birds',
      'dateTime': DateTime.now().subtract(const Duration(days: 1)),
      'durationSeconds': 125,
      'location': 'Backyard',
    },
    {
      'title': 'Rainy Night',
      'dateTime': DateTime.now().subtract(const Duration(hours: 5)),
      'durationSeconds': 300,
      'location': 'Window Sill',
    },
    {
      'title': 'Forest Ambience',
      'dateTime': DateTime.now().subtract(const Duration(days: 2, hours: 3)),
      'durationSeconds': 600,
      // 'location': null, // No location
    },
    {
      'title': 'Beach Waves',
      'dateTime': DateTime.now().subtract(const Duration(days: 5)),
      'durationSeconds': 240,
      'location': 'Sandy Beach',
    },
    {
      'title': 'City Park Sounds',
      'dateTime': DateTime.now().subtract(const Duration(hours: 12)),
      'durationSeconds': 180,
      'location': 'Central Park',
    },
    {
      'title': 'Night Crickets',
      'dateTime': DateTime.now().subtract(const Duration(days: 3)),
      'durationSeconds': 450,
      'location': 'Camping Site',
    },
    {
      'title': 'Night Crickets',
      'dateTime': DateTime.now().subtract(const Duration(days: 3)),
      'durationSeconds': 450,
      'location': 'Camping Site',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5.0),
                Text(
                  'My Sound Library',
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${_recordings.length} Recordings',
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _recordings.length,
                itemBuilder: (context, index) {
                  final recording = _recordings[index];
                  return RecordingListItem(
                    title: recording['title'],
                    dateTime: recording['dateTime'],
                    durationSeconds: recording['durationSeconds'],
                    location: recording['location'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
