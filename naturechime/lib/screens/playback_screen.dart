import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  bool _isPlaying = false;
  double _currentSliderValue = 0.0;
  Duration _currentPosition = Duration.zero;

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
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _onEdit() {
    // Create TextEditingControllers for the fields to be edited
    final titleController = TextEditingController(text: _title);
    final locationController = TextEditingController(text: _location ?? '');
    final notesController = TextEditingController(text: _notes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for keyboard overlapping
      builder: (BuildContext bottomSheetContext) {
        final colorScheme = Theme.of(bottomSheetContext).colorScheme;
        final textTheme = Theme.of(bottomSheetContext).textTheme;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom, // Adjust for keyboard
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
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Location (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes/Description (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    alignLabelWithHint: true, // Good for multiline
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(bottomSheetContext),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                      ),
                      child: const Text('Delete Recording'),
                      onPressed: () {
                        // Close the bottom sheet first
                        Navigator.pop(bottomSheetContext);
                        // Show confirmation dialog for delete
                        showDialog(
                          context: context, // Use the main screen's context
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text('Delete Recording?'),
                              content: const Text(
                                  'Are you sure you want to delete this recording? This action cannot be undone.'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () => Navigator.pop(dialogContext),
                                ),
                                TextButton(
                                  child: Text('Delete', style: TextStyle(color: colorScheme.error)),
                                  onPressed: () {
                                    Navigator.pop(dialogContext); // Close confirmation dialog
                                    // TODO: Implement actual delete logic (e.g., call a service, notify parent)
                                    debugPrint('Recording deleted: $_title');
                                    // Pop the PlaybackScreen after deletion
                                    if (mounted) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      child: const Text('Save Changes'),
                      onPressed: () {
                        setState(() {
                          _title = titleController.text;
                          _location =
                              locationController.text.isNotEmpty ? locationController.text : null;
                          _notes = notesController.text.isNotEmpty ? notesController.text : null;
                        });
                        Navigator.pop(bottomSheetContext); // Close the bottom sheet
                        debugPrint(
                            'Changes saved. Title: $_title, Location: $_location, Notes: $_notes');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20), // Spacing at the bottom
              ],
            ),
          ),
        );
      },
    );
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
