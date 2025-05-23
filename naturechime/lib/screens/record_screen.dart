import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naturechime/widgets/audio_level_indicator.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  bool _isRecording = false;
  final _currentAudioLevel = 0.9; // Example initial audio level
  final TextEditingController _titleController = TextEditingController(text: 'Recording title');

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      // TODO: Add actual recording start/stop logic here
      // TODO: If starting, begin timer and audio level updates
      // TODO: If stopping, stop timer and audio level updates
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get current date and time
    final now = DateTime.now();
    final formattedDate = DateFormat('d MMMM yyyy, h:mm a').format(now);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20),

              Text(
                'Record Sound',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall!.copyWith(color: colorScheme.onSurface),
              ),

              Text(
                formattedDate,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.normal,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 30),

              // Audio Level Indication
              AudioLevelIndicator(audioLevel: _currentAudioLevel, barCount: 20),

              const SizedBox(height: 30),

              // Placeholder for Recording Timer
              Text(
                '00:00:00', // Placeholder
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium!.copyWith(color: colorScheme.onSurface),
              ),

              const SizedBox(height: 40),

              // Record Button
              Center(
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: ElevatedButton(
                    onPressed: _toggleRecording,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      backgroundColor: _isRecording ? colorScheme.error : colorScheme.primary,
                      foregroundColor: _isRecording ? colorScheme.onError : colorScheme.onPrimary,
                    ),
                    child: Icon(
                      _isRecording ? CupertinoIcons.stop_fill : CupertinoIcons.mic_fill,
                      size: 40,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Recording Title Input
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: TextStyle(color: colorScheme.onSurface),
              ),

              const SizedBox(height: 40),

              // Discard and Save Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    width: 120, // Fixed width for both buttons
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement discard logic
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Discard'),
                      style: TextButton.styleFrom(foregroundColor: colorScheme.error),
                    ),
                  ),
                  SizedBox(
                    width: 120, // Fixed width for both buttons
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement save logic
                      },
                      icon: const Icon(Icons.save_alt_outlined),
                      label: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
