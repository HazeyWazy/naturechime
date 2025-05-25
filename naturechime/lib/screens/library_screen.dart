import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:naturechime/models/recording_model.dart';
import 'package:naturechime/widgets/recording_list_item.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
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
      setState(() {
        _loggedInUserId = currentUser.uid;
      });
      await _fetchUserRecordings();
    } else {
      setState(() {
        _isLoading = false;
        _recordings = [];
      });
      debugPrint("LibraryScreen: No user logged in.");
    }
  }

  Future<void> _fetchUserRecordings() async {
    if (_loggedInUserId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('recordings')
          .where('userId', isEqualTo: _loggedInUserId)
          .orderBy('createdAt', descending: true)
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
      debugPrint("Error fetching recordings: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load recordings: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                _isLoading
                    ? Text(
                        'Loading recordings...',
                        style: textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    : Text(
                        _loggedInUserId == null
                            ? 'Please log in to see your recordings'
                            : '${_recordings.length} Recordings',
                        style: textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
                  : _loggedInUserId == null
                      ? Center(
                          child: Text(
                            'You need to be logged in to view your library.',
                            style: textTheme.titleMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : _recordings.isEmpty
                          ? Center(
                              child: Text(
                                'No recordings in your library yet. Go make some!',
                                style: textTheme.titleMedium
                                    ?.copyWith(color: colorScheme.onSurfaceVariant),
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
                                  audioUrl: recording.audioUrl,
                                  recordingId: recording.id,
                                  onRefreshNeeded: _fetchUserRecordings,
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
