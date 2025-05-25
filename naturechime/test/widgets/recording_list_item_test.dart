import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:naturechime/widgets/recording_list_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

class MockUser extends Mock implements User {
  @override
  String get uid => 'test-user-id';
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  User? get currentUser => MockUser();
}

void main() {
  late DateTime testDateTime;

  Widget buildTestWidget(RecordingListItem child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  setUp(() {
    testDateTime = DateTime(2025, 3, 29, 6, 0); // March 29, 2025, 6:00 AM
  });

  group('RecordingListItem', () {
    testWidgets('displays all required information correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        RecordingListItem(
          title: 'Test Recording',
          dateTime: testDateTime,
          durationSeconds: 105, // 1:45
          username: 'TestUser',
          userId: 'test-user-id',
          audioUrl: 'test-url',
          recordingId: 'test-id',
        ),
      ));

      // Verify title
      expect(find.text('Test Recording'), findsOneWidget);

      // Verify date and duration format
      final formattedDateTime =
          DateFormat('d MMMM yyyy, h:mm a').format(testDateTime);
      expect(find.text('$formattedDateTime • 01:45'), findsOneWidget);

      // Verify presence of play button
      expect(find.byIcon(CupertinoIcons.play_arrow_solid), findsOneWidget);

      // Verify waveform icon in avatar
      expect(find.byIcon(CupertinoIcons.waveform), findsOneWidget);
    });

    testWidgets('displays location when provided', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        RecordingListItem(
          title: 'Test Recording',
          dateTime: testDateTime,
          durationSeconds: 105,
          location: 'Test Location',
          username: 'TestUser',
          userId: 'test-user-id',
          audioUrl: 'test-url',
          recordingId: 'test-id',
        ),
      ));

      expect(find.text('Test Location'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.location_solid), findsOneWidget);
    });

    testWidgets('does not display location when not provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        RecordingListItem(
          title: 'Test Recording',
          dateTime: testDateTime,
          durationSeconds: 105,
          username: 'TestUser',
          userId: 'test-user-id',
          audioUrl: 'test-url',
          recordingId: 'test-id',
        ),
      ));

      expect(find.byIcon(CupertinoIcons.location_solid), findsNothing);
    });

    testWidgets('handles long title with ellipsis',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        RecordingListItem(
          title:
              'Very Long Recording Title That Should Be Truncated With Ellipsis',
          dateTime: testDateTime,
          durationSeconds: 105,
          username: 'TestUser',
          userId: 'test-user-id',
          audioUrl: 'test-url',
          recordingId: 'test-id',
        ),
      ));

      final titleFinder = find.byType(Text).first;
      final Text titleWidget = tester.widget(titleFinder);
      expect(titleWidget.maxLines, 1);
      expect(titleWidget.overflow, TextOverflow.ellipsis);
    });
  });
}
