import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naturechime/screens/library_screen.dart';
import 'package:naturechime/screens/main_screen.dart';
import 'package:naturechime/widgets/recording_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Placeholder data for recordings
  final List<Map<String, dynamic>> _sampleRecordings = [
    {
      'title': 'Morning Birds Chirping',
      'dateTime': DateTime.now().subtract(const Duration(hours: 2)),
      'durationSeconds': 105,
      'location': 'Central Park, NYC',
    },
    {
      'title': 'Rainforest Ambience',
      'dateTime': DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      'durationSeconds': 300,
      'location': 'Amazon Rainforest',
    },
    {
      'title': 'Ocean Waves Sound',
      'dateTime': DateTime.now().subtract(const Duration(days: 3)),
      'durationSeconds': 180,
    },
  ];

  void _onRecordButtonPressed() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const MainScreen(initialIndex: 3), // record screen
      ),
    );
  }

  void _onSeeAllPressed() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const LibraryScreen(),
      ),
    );
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
              const SizedBox(height: 20),
              SizedBox(
                width: 90,
                height: 90,
                child: ElevatedButton(
                  onPressed: _onRecordButtonPressed,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: const Icon(
                    CupertinoIcons.mic_fill,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tap to record',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Recently Recorded',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _onSeeAllPressed,
                    icon: Text(
                      'See All',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                      ),
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
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Tap the microphone to start a new one!',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _sampleRecordings.length > 3 ? 3 : _sampleRecordings.length,
                  itemBuilder: (context, index) {
                    final recording = _sampleRecordings[index];
                    return RecordingListItem(
                      title: recording['title'] as String,
                      dateTime: recording['dateTime'] as DateTime,
                      durationSeconds: recording['durationSeconds'] as int,
                      location: recording['location'] as String?,
                    );
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
