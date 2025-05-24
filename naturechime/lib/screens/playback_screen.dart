import 'package:flutter/material.dart';

class PlaybackScreen extends StatelessWidget {
  const PlaybackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording Playback'),
      ),
      body: const Center(
        child: Text('Playback Screen'),
      ),
    );
  }
}
