import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naturechime/models/recording_model.dart';
import 'package:naturechime/screens/main_screen.dart';
import 'package:naturechime/widgets/recording_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Placeholder data for recordings, now using Recording model
  final List<Recording> _sampleRecordings = [
    Recording(
      id: 'home_rec_1',
      userId: 'user789',
      username: 'HomeUser1',
      title: 'Morning Birds Chirping',
      createdAt: Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
      durationSeconds: 105,
      location: 'Central Park, NYC',
      audioUrl: 'https://example.com/home_audio1.mp3',
      notes: 'A pleasant morning soundscape.',
    ),
    Recording(
      id: 'home_rec_2',
      userId: 'userABC',
      username: 'HomeUser2',
      title: 'Rainforest Ambience',
      createdAt: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1, hours: 5))),
      durationSeconds: 300,
      location: 'Amazon Rainforest',
      audioUrl: 'https://example.com/home_audio2.mp3',
      notes: 'Deep forest sounds.',
    ),
    Recording(
      id: 'home_rec_3',
      userId: 'userXYZ',
      username: 'HomeUser3',
      title: 'Ocean Waves Sound',
      createdAt: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
      durationSeconds: 180,
      location: null,
      audioUrl: 'https://example.com/home_audio3.mp3',
      notes: null,
    ),
  ];

  void _onRecordButtonPressed() {
    final isMainScreenOnTop =
        ModalRoute.of(context)?.settings.name == '/'; // Assuming MainScreen is your home route

    if (isMainScreenOnTop && mounted) {
      // If MainScreen is already visible, try to update its index if possible
      // This requires MainScreen's state to be accessible, e.g. via a GlobalKey or inherited widget.
      // For now, we'll just navigate, which re-instantiates MainScreen with the new index.
      // This is what the original code was doing by pushing MainScreen.
      Navigator.of(context).pushReplacement(
        // Using pushReplacement to avoid stacking MainScreens
        CupertinoPageRoute(
          builder: (context) => const MainScreen(initialIndex: 3),
        ),
      );
    } else {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => const MainScreen(initialIndex: 3),
        ),
      );
    }
  }

  void _onSeeAllPressed() {
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(
        builder: (context) => const MainScreen(initialIndex: 1), // 1 is Library tab index
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
