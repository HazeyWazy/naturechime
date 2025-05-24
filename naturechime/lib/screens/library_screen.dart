import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:naturechime/models/recording_model.dart';
import 'package:naturechime/widgets/recording_list_item.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Recording> _recordings = [
    Recording(
      id: 'lib_rec_1',
      userId: 'user123',
      username: 'LibraryUser1',
      title: 'Morning Birds',
      createdAt: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
      durationSeconds: 125,
      location: 'Backyard',
      audioUrl: 'https://example.com/lib_audio1.mp3',
      notes: 'Clear morning sounds.',
    ),
    Recording(
      id: 'lib_rec_2',
      userId: 'user456',
      username: 'LibraryUser2',
      title: 'Rainy Night',
      createdAt: Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 5))),
      durationSeconds: 300,
      location: 'Window Sill',
      audioUrl: 'https://example.com/lib_audio2.mp3',
      notes: 'Soothing rain.',
    ),
    Recording(
      id: 'lib_rec_3',
      userId: 'user789',
      username: 'LibraryUser3',
      title: 'Forest Ambience',
      createdAt: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2, hours: 3))),
      durationSeconds: 600,
      location: null, // No location
      audioUrl: 'https://example.com/lib_audio3.mp3',
      notes: null,
    ),
    Recording(
      id: 'lib_rec_4',
      userId: 'user123',
      username: 'LibraryUser1', // Same user, different recording
      title: 'Beach Waves',
      createdAt: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5))),
      durationSeconds: 240,
      location: 'Sandy Beach',
      audioUrl: 'https://example.com/lib_audio4.mp3',
      notes: 'Peaceful waves.',
    ),
    Recording(
      id: 'lib_rec_5',
      userId: 'userABC',
      username: 'LibraryUser4',
      title: 'City Park Sounds',
      createdAt: Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 12))),
      durationSeconds: 180,
      location: 'Central Park',
      audioUrl: 'https://example.com/lib_audio5.mp3',
      notes: 'Urban soundscape.',
    ),
    Recording(
      id: 'lib_rec_6',
      userId: 'userXYZ',
      username: 'LibraryUser5',
      title: 'Night Crickets',
      createdAt: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
      durationSeconds: 450,
      location: 'Camping Site',
      audioUrl: 'https://example.com/lib_audio6.mp3',
      notes: 'Loud crickets!',
    ),
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
              child: _recordings.isEmpty
                  ? Center(
                      child: Text(
                        'No recordings in your library yet.',
                        style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _recordings.length,
                      itemBuilder: (context, index) {
                        final recording = _recordings[index];
                        return RecordingListItem(
                          key: ValueKey(recording.id),
                          title: recording.title,
                          dateTime: recording.createdAt.toDate(),
                          durationSeconds: recording.durationSeconds,
                          location: recording.location,
                          username: recording.username ?? 'Unknown User',
                          userId: recording.userId,
                          notes: recording.notes,
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
