import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecordButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onPressed;
  final bool isLoading; // Added to handle loading state, e.g., during upload

  const RecordButton({
    super.key,
    required this.isRecording,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 90,
      height: 90,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // Disable if loading
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
          backgroundColor: isRecording ? colorScheme.error : colorScheme.primary,
          foregroundColor: isRecording ? colorScheme.onError : colorScheme.onPrimary,
        ),
        child: isLoading
            ? SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: isRecording ? colorScheme.onError : colorScheme.onPrimary,
                ),
              )
            : Icon(
                isRecording ? CupertinoIcons.stop_fill : CupertinoIcons.mic_fill,
                size: 40,
              ),
      ),
    );
  }
}
