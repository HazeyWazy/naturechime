import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:naturechime/screens/explore_screen.dart';
import 'package:naturechime/widgets/recording_list_item.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: ExploreScreen(firestore: fakeFirestore),
      ),
    );
  }

  Future<void> addTestRecording({
    required String title,
    required String location,
    required String username,
  }) async {
    await fakeFirestore.collection('recordings').add({
      'title': title,
      'createdAt': Timestamp.now(),
      'durationSeconds': 10,
      'location': location,
      'username': username,
      'notes': '',
      'userId': 'testUser',
      'audioUrl': 'test_url',
    });
  }

  testWidgets('Displays loading indicator while fetching data', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Displays recordings when data is loaded', (tester) async {
    await addTestRecording(
      title: 'Birdsong',
      location: 'Forest',
      username: 'Alice',
    );
    await addTestRecording(
      title: 'Rain',
      location: 'City',
      username: 'Bob',
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Birdsong'), findsOneWidget);
    expect(find.text('Rain'), findsOneWidget);
    expect(find.byType(RecordingListItem), findsNWidgets(2));
  });

  testWidgets('Filters recordings by title, location, and username',
      (tester) async {
    await addTestRecording(
      title: 'Ocean',
      location: 'Beach',
      username: 'Charlie',
    );
    await addTestRecording(
      title: 'Wind',
      location: 'Mountain',
      username: 'Dana',
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Filter by title
    await tester.enterText(find.byType(TextField), 'Ocean');
    await tester.pumpAndSettle();
    expect(find.byType(RecordingListItem), findsOneWidget);
    expect(find.descendant(
      of: find.byType(RecordingListItem),
      matching: find.text('Ocean')
    ), findsOneWidget);
    expect(find.byType(RecordingListItem).evaluate().length, 1);

    // Filter by location
    await tester.enterText(find.byType(TextField), 'Mountain');
    await tester.pumpAndSettle();
    expect(find.descendant(
      of: find.byType(RecordingListItem),
      matching: find.text('Wind')
    ), findsOneWidget);
    expect(find.descendant(
      of: find.byType(RecordingListItem),
      matching: find.text('Ocean')
    ), findsNothing);

    // Filter by username
    await tester.enterText(find.byType(TextField), 'Charlie');
    await tester.pumpAndSettle();
    expect(find.descendant(
      of: find.byType(RecordingListItem),
      matching: find.text('Ocean')
    ), findsOneWidget);
    expect(find.descendant(
      of: find.byType(RecordingListItem),
      matching: find.text('Wind')
    ), findsNothing);
  });

  testWidgets('Shows message when search yields no results', (tester) async {
    await addTestRecording(
      title: 'Thunder',
      location: 'Valley',
      username: 'Eve',
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'NoMatch');
    await tester.pumpAndSettle();
    expect(
        find.text('No recordings found matching your search.'), findsOneWidget);
  });

  testWidgets('Search is case-insensitive', (tester) async {
    await addTestRecording(
      title: 'River',
      location: 'Lake',
      username: 'Frank',
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'river');
    await tester.pumpAndSettle();
    expect(find.text('River'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'LAKE');
    await tester.pumpAndSettle();
    expect(find.text('River'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'frank');
    await tester.pumpAndSettle();
    expect(find.text('River'), findsOneWidget);
  });
}
