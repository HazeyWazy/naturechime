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
  // Use a Future to hold the recordings from Firestore
  Future<List<Recording>>? _recordingsFuture;
  List<Recording> _allRecordings = []; // To store all fetched recordings
  List<Recording> _filteredRecordings = []; // For displaying filtered results
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _recordingsFuture = _fetchRecordingsFromFirestore();
    _searchController.addListener(_filterRecordings);
  }

  Future<List<Recording>> _fetchRecordingsFromFirestore() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('recordings').get();
      _allRecordings =
          querySnapshot.docs.map((doc) => Recording.fromFirestore(doc.data(), doc.id)).toList();
      // Initially, filtered recordings are all recordings
      _filteredRecordings = List.from(_allRecordings);
      return _allRecordings;
    } catch (e) {
      debugPrint('Error fetching recordings: $e');
      return []; // Return empty list on error
    }
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
      // Filter from _allRecordings
      _filteredRecordings = _allRecordings.where((recording) {
        final titleMatch = recording.title.toLowerCase().contains(query);
        final locationMatch = recording.location?.toLowerCase().contains(query) ?? false;
        final usernameMatch = recording.username?.toLowerCase().contains(query) ?? false;
        return titleMatch || locationMatch || usernameMatch;
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
            child: FutureBuilder<List<Recording>>(
              future: _recordingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  debugPrint('Snapshot error: ${snapshot.error}');
                  return Center(
                    child: Text(
                      'Error loading recordings. Please try again later.',
                      style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No recordings available yet.',
                      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // Use _filteredRecordings for the list view
                if (_filteredRecordings.isEmpty && _searchController.text.isNotEmpty) {
                  return Center(
                    child: Text(
                      'No recordings found matching your search.',
                      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // If search is empty and _allRecordings is empty (covered by !snapshot.hasData),
                // or if search has text but _filteredRecordings is empty.
                // The list to display is always _filteredRecordings.
                // If _allRecordings is not empty but _filteredRecordings becomes empty due to search,
                // then the "No recordings found matching your search" message is shown.
                // If _allRecordings is initially empty, "No recordings available yet" is shown.

                final recordingsToShow = _searchController.text.isEmpty &&
                        _filteredRecordings.isEmpty &&
                        _allRecordings.isNotEmpty
                    ? _allRecordings // Show all if search is empty and filtered is empty (implies initial load with data)
                    : _filteredRecordings;

                if (recordingsToShow.isEmpty && _searchController.text.isNotEmpty) {
                  return Center(
                    child: Text(
                      'No recordings found matching your search.',
                      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (recordingsToShow.isEmpty && _allRecordings.isEmpty) {
                  return Center(
                    child: Text(
                      'No recordings available yet.',
                      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8.0),
                  itemCount: recordingsToShow.length,
                  itemBuilder: (context, index) {
                    final recording = recordingsToShow[index];
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
