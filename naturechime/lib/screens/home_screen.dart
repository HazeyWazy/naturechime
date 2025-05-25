import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  List<Recording> _recordings = [];
  bool _isLoading = true;
  String? _loggedInUserId;

  @override
  void initState() {
    super.initState();
    _getLoggedInUserAndFetchRecordings();
  }

  Future<void> _getLoggedInUserAndFetchRecordings() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      if (mounted) {
        setState(() {
          _loggedInUserId = currentUser.uid;
        });
      }
      await _fetchUserRecordings();
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _recordings = [];
        });
      }
      debugPrint("HomeScreen: No user logged in.");
    }
  }

  Future<void> _fetchUserRecordings() async {
    if (_loggedInUserId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('recordings')
          .where('userId', isEqualTo: _loggedInUserId)
          .orderBy('createdAt', descending: true)
          .limit(4) // Limit to 4 most recent recordings
          .get();

      final fetchedRecordings =
          querySnapshot.docs.map((doc) => Recording.fromFirestore(doc.data(), doc.id)).toList();

      if (mounted) {
        setState(() {
          _recordings = fetchedRecordings;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching recordings for HomeScreen: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load recent recordings: ${e.toString()}')),
        );
      }
    }
  }

  void _onRecordButtonPressed() {
    final isMainScreenOnTop = ModalRoute.of(context)?.settings.name == '/';

    if (isMainScreenOnTop && mounted) {
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
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              else if (_recordings.isEmpty)
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
                      audioUrl: recording.audioUrl,
                      recordingId: recording.id,
                      onRefreshNeeded: _fetchUserRecordings,
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
