import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:naturechime/screens/library_screen.dart';
import '../firebase_auth_mocks.dart';

// Mock RecordingListItem to avoid rendering complexities in LibraryScreen tests
class MockRecordingListItem extends StatelessWidget {
  final String title;
  final DateTime dateTime;
  final int durationSeconds;
  final String? location;
  final String username;
  final String userId;
  final String? notes;
  final String audioUrl;
  final String recordingId;
  final VoidCallback onRefreshNeeded;

  const MockRecordingListItem({
    super.key,
    required this.title,
    required this.dateTime,
    required this.durationSeconds,
    this.location,
    required this.username,
    required this.userId,
    this.notes,
    required this.audioUrl,
    required this.recordingId,
    required this.onRefreshNeeded,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: const Text('Mock Recording Item'),
    );
  }
}

void main() {
  setUpAll(() async {
    await setupFirebaseAuthMocks();
  });

  // ignore: unused_local_variable
  late FakeFirebaseFirestore fakeFirestore;
  // ignore: unused_local_variable
  late MockFirebaseAuth mockAuth;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  // Helper function to build the LibraryScreen widget
  Widget createLibraryScreen() {
    return const MaterialApp(
      home: LibraryScreen(),
    );
  }

  testWidgets('No User Logged In - Shows login message and title', (WidgetTester tester) async {
    mockAuth = MockFirebaseAuth(signedIn: false);
    await tester.pumpAndSettle();

    await tester.pumpWidget(createLibraryScreen());
    await tester.pumpAndSettle(); // Allow all state changes to complete

    expect(find.text('My Sound Library'), findsOneWidget);
    expect(find.text('You need to be logged in to view your library.'), findsOneWidget);
  });
}
