import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naturechime/widgets/record_button.dart';
import 'package:naturechime/widgets/recording_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRecording = false; // Placeholder state

  // Placeholder data for recordings
  // Replace with actual data fetching logic
  final List<Map<String, dynamic>> _sampleRecordings = [
    {
      'title': 'Morning Birds Chirping',
      'dateTime': DateTime.now().subtract(const Duration(hours: 2)),
      'durationSeconds': 105, // 1 minute 45 seconds
      'location': 'Central Park, NYC',
    },
    {
      'title': 'Rainforest Ambience',
      'dateTime': DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      'durationSeconds': 300, // 5 minutes
      'location': 'Amazon Rainforest',
    },
    {
      'title': 'Ocean Waves Sound',
      'dateTime': DateTime.now().subtract(const Duration(days: 3)),
      'durationSeconds': 180, // 3 minutes
      // 'location': null, // Example with no location
    },
  ];

  void _onRecordButtonPressed() {
    // Navigate to RecordScreen or handle recording logic
    // For now, just toggle the placeholder state
    setState(() {
      _isRecording = !_isRecording;
    });
    debugPrint("Record button pressed. Is recording: $_isRecording");
    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => RecordScreen()));
  }

  void _onPlayRecordingPressed(Map<String, dynamic> recording) {
    // Handle play recording logic
    debugPrint("Play pressed for: \${recording['title']}");
    // Example: Navigate to a player screen or use an audio player service
  }

  void _onSeeAllPressed() {
    // Navigate to a screen showing all recordings
    debugPrint("See All pressed");
    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => AllRecordingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 40),
              RecordButton(
                isRecording: _isRecording, // Use actual recording state
                onPressed: _onRecordButtonPressed,
              ),
              const SizedBox(height: 16),
              Text(
                'Tap to record',
                style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Recently Recorded',
                    style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
                  ),
                  TextButton.icon(
                    onPressed: _onSeeAllPressed,
                    icon: Text(
                      'See All',
                      style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
                    ),
                    label: Icon(
                      CupertinoIcons.chevron_forward,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_sampleRecordings.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.moon_zzz,
                          size: 60,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No recordings yet.',
                          style:
                              textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        Text(
                          'Tap the microphone to start a new one!',
                          style:
                              textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true, // Important for ListView inside SingleChildScrollView
                  physics: const NeverScrollableScrollPhysics(), // Disable ListView's own scrolling
                  itemCount: _sampleRecordings.length > 3
                      ? 3
                      : _sampleRecordings.length, // Show max 3 or less
                  itemBuilder: (context, index) {
                    final recording = _sampleRecordings[index];
                    return RecordingListItem(
                      title: recording['title'] as String,
                      dateTime: recording['dateTime'] as DateTime,
                      durationSeconds: recording['durationSeconds'] as int,
                      location: recording['location'] as String?,
                      onPlay: () => _onPlayRecordingPressed(recording),
                    );
                  },
                ),
              const SizedBox(height: 20), // Add some padding at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
