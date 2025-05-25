import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturechime/screens/playback_screen.dart';

void main() {
  testWidgets('PlaybackScreen renders initial state correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: PlaybackScreen(
        initialTitle: 'Test Recording',
        initialUsername: 'testUser',
        initialDurationSeconds: 120,
        audioUrl: 'test.mp3',
        recordingId: 'test123',
      ),
    ));

    expect(find.text('Test Recording'), findsOneWidget);
    expect(find.text('By testUser'), findsOneWidget);
    // Change this line to use the correct Cupertino play icon
    expect(find.byIcon(CupertinoIcons.play_fill), findsOneWidget);
  });

  testWidgets('PlaybackScreen shows location when provided',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: PlaybackScreen(
        initialTitle: 'Test Recording',
        initialUsername: 'testUser',
        initialLocation: 'Test Location',
        initialDurationSeconds: 120,
        audioUrl: 'test.mp3',
        recordingId: 'test123',
      ),
    ));

    expect(find.text('By testUser at Test Location'), findsOneWidget);
  });

  testWidgets('PlaybackScreen displays notes when provided',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: PlaybackScreen(
        initialTitle: 'Test Recording',
        initialUsername: 'testUser',
        initialNotes: 'Test notes',
        initialDurationSeconds: 120,
        audioUrl: 'test.mp3',
        recordingId: 'test123',
      ),
    ));

    expect(find.text('Test notes'), findsOneWidget);
  });

  testWidgets('Edit button shows only for current user recordings',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: PlaybackScreen(
        initialTitle: 'Test Recording',
        initialUsername: 'testUser',
        initialDurationSeconds: 120,
        isCurrentUserRecording: true,
        audioUrl: 'test.mp3',
        recordingId: 'test123',
      ),
    ));

    expect(find.byIcon(CupertinoIcons.create), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(
      home: PlaybackScreen(
        initialTitle: 'Test Recording',
        initialUsername: 'testUser',
        initialDurationSeconds: 120,
        isCurrentUserRecording: false,
        audioUrl: 'test.mp3',
        recordingId: 'test123',
      ),
    ));

    expect(find.byIcon(CupertinoIcons.create), findsNothing);
  });
}