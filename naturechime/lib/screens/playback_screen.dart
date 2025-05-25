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
    // TODO: Implement edit functionality (e.g., show a dialog or navigate to an edit screen)
    debugPrint('Edit button tapped. Title: $_title, Notes: $_notes');
    // For now, let's simulate an edit
    // setState(() {
    //   _title = "Edited Title";
    //   _notes = "These are some edited notes.";
    // });
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
