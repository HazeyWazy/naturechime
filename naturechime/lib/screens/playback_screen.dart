import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlaybackScreen extends StatefulWidget {
  // TODO: Pass actual recording data to this screen
  final String initialTitle;
  final DateTime? initialDateTime;
  final String? initialLocation;
  final String initialUsername;
  final String? initialNotes;
  final int initialDurationSeconds;
  final bool isCurrentUserRecording;
  final String audioUrl;
  final String recordingId; // Firestore document ID

  const PlaybackScreen({
    super.key,
    this.initialTitle = 'Forest Ambience',
    this.initialDateTime,
    this.initialLocation = 'Amazon Rainforest',
    this.initialUsername = 'NatureLover23',
    this.initialNotes =
        'A beautiful morning in the rainforest, birds chirping and leaves rustling. Captured the essence perfectly.',
    this.initialDurationSeconds = 300, // 5 minutes
    this.isCurrentUserRecording = false, // Default to false
    required this.audioUrl,
    required this.recordingId, // Add this
  });

  @override
  State<PlaybackScreen> createState() => _PlaybackScreenState();
}

class _PlaybackScreenState extends State<PlaybackScreen> {
  late String _title;
  late DateTime _dateTime;
  late String? _location;
  late String _username;
  late String? _notes;
  late int _totalDurationSeconds;
  late String _recordingId; // Store the ID in state

  bool _isPlaying = false;
  double _currentSliderValue = 0.0;
  Duration _currentPosition = Duration.zero;
  bool _didEditOccur = false; // Flag to track if an edit was made and saved

  @override
  void initState() {
    super.initState();
    _title = widget.initialTitle;
    _dateTime =
        widget.initialDateTime ?? DateTime.now().subtract(const Duration(days: 2, hours: 3));
    _location = widget.initialLocation;
    _username = widget.initialUsername;
    _notes = widget.initialNotes;
    _totalDurationSeconds = widget.initialDurationSeconds;
    _recordingId = widget.recordingId; // Initialize it
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _onEdit() async {
    final titleController = TextEditingController(text: _title);
    final locationController = TextEditingController(text: _location ?? '');
    final notesController = TextEditingController(text: _notes ?? '');

    final bool? changesSavedInModal = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        final colorScheme = Theme.of(bottomSheetContext).colorScheme;
        final textTheme = Theme.of(bottomSheetContext).textTheme;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
            left: 16.0,
            right: 16.0,
            top: 20.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Edit Recording Details',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainer,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Location (Optional)',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainer,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Notes/Description (Optional)',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: colorScheme.surfaceContainer,
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: Text('Cancel', style: TextStyle(color: colorScheme.primary)),
                      onPressed: () =>
                          Navigator.pop(bottomSheetContext, false), // Return false on cancel
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                      ),
                      child: const Text('Delete Recording'),
                      onPressed: () async {
                        Navigator.pop(bottomSheetContext); // Close modal first
                        // Show confirmation dialog for delete
                        final bool? deleteConfirmed = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: Text(
                                'Delete Recording?',
                                style: TextStyle(color: colorScheme.onSurface),
                              ),
                              content: Text(
                                'Are you sure you want to delete this recording? This action cannot be undone.',
                                style: TextStyle(color: colorScheme.onSurfaceVariant),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child:
                                      Text('Cancel', style: TextStyle(color: colorScheme.primary)),
                                  onPressed: () => Navigator.pop(dialogContext, false),
                                ),
                                TextButton(
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: colorScheme.error),
                                  ),
                                  onPressed: () => Navigator.pop(dialogContext, true),
                                ),
                              ],
                            );
                          },
                        );

                        if (deleteConfirmed == true && mounted) {
                          try {
                            debugPrint('Attempting to delete Firestore document: $_recordingId');
                            await FirebaseFirestore.instance
                                .collection('recordings')
                                .doc(_recordingId)
                                .delete();
                            debugPrint('Firestore document $_recordingId deleted.');
                            debugPrint(
                                'Recording "$_title" deleted (Firestore & simulated storage).');

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Recording "$_title" deleted successfully.'),
                                  backgroundColor: colorScheme.primary,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              Navigator.pop(
                                  context, true); // Pop PlaybackScreen with true for deletion
                            }
                          } catch (e) {
                            debugPrint('Error deleting recording: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to delete recording: $e'),
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      child: const Text('Save Changes'),
                      onPressed: () async {
                        // Make async for Firestore call
                        // Prepare data for Firestore update
                        final updatedData = {
                          'title': titleController.text,
                          'location':
                              locationController.text.isNotEmpty ? locationController.text : null,
                          'notes': notesController.text.isNotEmpty ? notesController.text : null,
                        };

                        // It's good practice to ensure the widget is still mounted
                        if (!mounted) return;

                        try {
                          // Show a loading indicator perhaps, or disable the button
                          debugPrint(
                              "Attempting to update Firestore document: $_recordingId with data: $updatedData");

                          // Update Firestore
                          await FirebaseFirestore.instance
                              .collection('recordings')
                              .doc(_recordingId)
                              .update(updatedData);

                          debugPrint("Firestore document $_recordingId updated successfully.");

                          // Update local state only AFTER successful Firestore update
                          setState(() {
                            _title = titleController.text;
                            _location =
                                locationController.text.isNotEmpty ? locationController.text : null;
                            _notes = notesController.text.isNotEmpty ? notesController.text : null;
                            // _didEditOccur is set outside this modal's pop
                          });

                          if (mounted && bottomSheetContext.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Changes saved successfully!'),
                                backgroundColor: colorScheme.primary,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.pop(
                                bottomSheetContext, true); // Return true: changes were saved
                          }
                        } catch (e) {
                          debugPrint("Error updating Firestore document $_recordingId: $e");
                          if (mounted && bottomSheetContext.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error saving changes: $e'),
                                backgroundColor: Theme.of(context).colorScheme.error,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.pop(
                                bottomSheetContext, false); // Return false: error occurred
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );

    // If changes were saved in the modal, update the flag. Do NOT pop PlaybackScreen.
    if (changesSavedInModal == true) {
      setState(() {
        _didEditOccur = true;
      });
    }
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        if (_currentSliderValue == 0) {
          _currentSliderValue = 0.1;
          _currentPosition =
              Duration(seconds: (_totalDurationSeconds * _currentSliderValue).toInt());
        }
        debugPrint('Playing...');
      } else {
        debugPrint('Paused...');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final formattedDateTime = DateFormat('d MMMM yyyy, h:mm a').format(_dateTime);
    final totalDuration = Duration(seconds: _totalDurationSeconds);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          // Custom back button
          icon: Icon(Theme.of(context).platform == TargetPlatform.iOS
              ? CupertinoIcons.back
              : Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _didEditOccur); // Pop with the flag
          },
        ),
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        title: Text(
          'Recording Playback',
          style: TextStyle(color: colorScheme.onPrimary),
        ),
        backgroundColor: colorScheme.primary,
        toolbarHeight: kToolbarHeight + 15,
        actions: [
          if (widget.isCurrentUserRecording) // Conditionally show edit button
            IconButton(
              icon: Icon(
                CupertinoIcons.create,
                color: colorScheme.onPrimary,
              ),
              onPressed: _onEdit,
              tooltip: 'Edit Recording',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _title,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Recorded on $formattedDateTime',
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'By $_username${_location != null && _location!.isNotEmpty ? " at $_location" : ""}',
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      if (_notes != null && _notes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: Text(
                            _notes!,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface,
                              height: 1.5,
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 24), // Maintain some space if no notes
                    ],
                  ),
                ),
              ),
            ),
            // Playback Controls Section
            const SizedBox(height: 16), // Spacing before controls
            Slider(
              value: _currentSliderValue,
              min: 0.0,
              max: 1.0,
              onChanged: (value) {
                setState(() {
                  _currentSliderValue = value;
                  _currentPosition = Duration(
                    seconds: (_totalDurationSeconds * value).toInt(),
                  );
                });
              },
              activeColor: colorScheme.primary,
              inactiveColor: colorScheme.surfaceContainerHighest,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_currentPosition),
                    style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    _formatDuration(totalDuration),
                    style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: IconButton(
                icon: Icon(
                  _isPlaying ? CupertinoIcons.pause_solid : CupertinoIcons.play_arrow_solid,
                  size: 50,
                  color: colorScheme.primary,
                ),
                onPressed: _togglePlayPause,
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
