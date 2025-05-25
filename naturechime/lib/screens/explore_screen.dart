import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naturechime/models/recording_model.dart';
import 'package:naturechime/widgets/recording_list_item.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // Use a Stream to hold the recordings from Firestore for real-time updates
  Stream<List<Recording>>? _recordingsStream;
  List<Recording> _allRecordings = []; // To store all fetched recordings from the stream
  List<Recording> _filteredRecordings = []; // For displaying filtered results
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _recordingsStream = _getRecordingsStream();
    _searchController.addListener(() {
      _applyFilter();
      // Ensure UI rebuilds when search text changes
      if (mounted) {
        setState(() {});
      }
    });
  }

  Stream<List<Recording>> _getRecordingsStream() {
    return FirebaseFirestore.instance
        .collection('recordings')
        .orderBy('createdAt', descending: true) // Show newest first
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) => Recording.fromFirestore(doc.data(), doc.id)).toList();
      } catch (e) {
        debugPrint('Error mapping recordings stream: $e');
        return []; // Return empty list on error during mapping
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter); // Should match the added listener
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredRecordings = List.from(_allRecordings);
    } else {
      _filteredRecordings = _allRecordings.where((recording) {
        final titleMatch = recording.title.toLowerCase().contains(query);
        final locationMatch = recording.location?.toLowerCase().contains(query) ?? false;
        final usernameMatch = recording.username?.toLowerCase().contains(query) ?? false;
        return titleMatch || locationMatch || usernameMatch;
      }).toList();
    }
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
            child: StreamBuilder<List<Recording>>(
              stream: _recordingsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint('StreamBuilder error: ${snapshot.error}');
                  return Center(
                    child: Text(
                      'Error loading recordings. Please try again later.',
                      style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                _allRecordings = snapshot.data ?? [];
                _applyFilter(); // Apply search filter to the latest data

                if (_allRecordings.isEmpty) {
                  return Center(
                    child: Text(
                      'No recordings available yet.',
                      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (_filteredRecordings.isEmpty && _searchController.text.isNotEmpty) {
                  return Center(
                    child: Text(
                      'No recordings found matching your search.',
                      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // If _filteredRecordings is empty and search is also empty,
                // it implies _allRecordings was empty, handled by the first check.

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8.0),
                  itemCount: _filteredRecordings.length, // Display filtered recordings
                  itemBuilder: (context, index) {
                    final recording = _filteredRecordings[index];
                    return RecordingListItem(
                      key: ValueKey(recording.id),
                      title: recording.title,
                      // Convert Timestamp to DateTime for the UI widget
                      dateTime: recording.createdAt.toDate(),
                      durationSeconds: recording.durationSeconds,
                      location: recording.location,
                      username: recording.username ?? 'Unknown User', // Provide a fallback
                      notes: recording.notes,
                      userId: recording.userId,
                      audioUrl: recording.audioUrl,
                      recordingId: recording.id,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
