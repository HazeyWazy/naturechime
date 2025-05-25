import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naturechime/screens/playback_screen.dart';

const String currentUserId = 'user123';

class RecordingListItem extends StatelessWidget {
  final String title;
  final DateTime dateTime;
  final int durationSeconds;
  final String? location;
  final String username;
  final String? notes;
  final String userId;
  final String audioUrl;

  const RecordingListItem({
    super.key,
    required this.title,
    required this.dateTime,
    required this.durationSeconds,
    this.location,
    required this.username,
    this.notes,
    required this.userId,
    required this.audioUrl,
  });

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds"; // Format as MM:SS
  }

  void _navigateToPlayback(BuildContext context) {
    Navigator.push(
      context,
      CupertinoModalPopupRoute(
        builder: (context) => PlaybackScreen(
          initialTitle: title,
          initialDateTime: dateTime,
          initialLocation: location,
          initialUsername: username,
          initialNotes: notes,
          initialDurationSeconds: durationSeconds,
          isCurrentUserRecording: userId == currentUserId,
          audioUrl: audioUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Format: 29 March 2025, 6:00 AM • 01:45
    final formattedDateTime = DateFormat('d MMMM yyyy, h:mm a').format(dateTime);
    final formattedDuration = _formatDuration(durationSeconds);
    final subtitleText = '$formattedDateTime • $formattedDuration';

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 6.0,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          child: const Icon(CupertinoIcons.waveform),
        ),
        title: Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitleText,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (location != null && location!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.location_solid,
                      size: 14,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            CupertinoIcons.play_arrow_solid,
            color: colorScheme.primary,
            size: 30,
          ),
          onPressed: () => _navigateToPlayback(context),
        ),
        onTap: () => _navigateToPlayback(context),
      ),
    );
  }
}
