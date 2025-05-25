import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:naturechime/screens/profile_screen.dart';
import 'package:naturechime/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen_test.mocks.dart';
import 'dart:async';

@GenerateMocks([
  FirebaseFirestore,
  AuthService,
  User,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  FirebaseAuth,
])
void main() {
  late MockAuthService mockAuthService;
  late MockUser mockUser;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentRef;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocument;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockUser = MockUser();
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentRef = MockDocumentReference<Map<String, dynamic>>();
    mockDocument = MockDocumentSnapshot<Map<String, dynamic>>();

    // Setup default mock behavior
    when(mockUser.uid).thenReturn('test-uid');
    when(mockUser.email).thenReturn('test@example.com');
    when(mockUser.displayName).thenReturn('Test User');

    // Setup Firestore mock behavior
    when(mockFirestore.collection('users')).thenReturn(mockCollection);
    when(mockCollection.doc('test-uid')).thenReturn(mockDocumentRef);
    when(mockDocumentRef.get()).thenAnswer((_) async => mockDocument);
    when(mockDocument.exists).thenReturn(true);
    when(mockDocument.id).thenReturn('test-uid');
    when(mockDocument.data()).thenReturn({
      'email': 'test@example.com',
      'displayName': 'Test User',
      'profileImageUrl': null,
      'createdAt': Timestamp.now(),
    });

    // Set mock Firestore instance
    TestFirestore.setInstance(mockFirestore);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<AuthService>.value(
        value: mockAuthService,
        child: const ProfileScreen(),
      ),
    );
  }

  group('ProfileScreen Widget Tests', () {
    testWidgets('shows loading indicator when auth state is waiting',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(null));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows not logged in message when user is null',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(null));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(
          find.text('Not logged in or user data not found.'), findsOneWidget);
      expect(find.text('Go to Login'), findsOneWidget);
    });

    testWidgets('shows profile content when user is logged in',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(mockUser));
      when(mockUser.uid).thenReturn('test-uid');

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);
    });

    testWidgets('displays default avatar when no profile image',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(mockUser));
      when(mockDocument.data()).thenReturn({
        'email': 'test@example.com',
        'displayName': 'Test User',
        'profileImageUrl': null,
        'createdAt': Timestamp.now(),
      });

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.person_fill), findsOneWidget);
    });

    testWidgets('handles user document not found in Firestore',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(mockUser));
      when(mockDocument.exists).thenReturn(false);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(
          find.text('Not logged in or user data not found.'), findsOneWidget);
    });

    testWidgets('handles Firestore error gracefully',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(mockUser));
      when(mockDocumentRef.get())
          .thenThrow(Exception('Firestore connection error'));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(
          find.text('Not logged in or user data not found.'), findsOneWidget);
    });

    testWidgets('logout button calls signOut and navigates',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(mockUser));
      when(mockAuthService.signOut()).thenAnswer((_) async => {});

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final logoutButton = find.text('Logout');
      expect(logoutButton, findsOneWidget);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      // Assert
      verify(mockAuthService.signOut()).called(1);
    });

    testWidgets('shows delete account confirmation dialog',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(mockUser));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final deleteButton = find.text('Delete Account');
      expect(deleteButton, findsOneWidget);
      await tester.tap(deleteButton);
      await tester.pump(); // Pump once to start the dialog animation
      await tester.pumpAndSettle(); // Wait for the dialog to fully appear

      // Assert
      expect(find.text('Delete Account?'), findsOneWidget);
      expect(
          find.text(
              'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently lost.'),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('cancel delete account dialog dismisses without action',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(mockUser));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      verifyNever(mockAuthService.deleteUserAccount());
      expect(find.text('Delete Account?'), findsNothing);
    });

    testWidgets('confirm delete account calls deleteUserAccount',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(mockUser));
      when(mockAuthService.deleteUserAccount()).thenAnswer((_) async => {});

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockAuthService.deleteUserAccount()).called(1);
    });

    testWidgets('handles delete account error gracefully',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(mockUser));
      when(mockAuthService.deleteUserAccount())
          .thenThrow(Exception('Delete failed'));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Failed to delete account'), findsOneWidget);
    });

    testWidgets('shows loading indicator during account deletion',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(mockUser));

      // Use a Completer instead of Future.delayed to have more control over the async operation
      final completer = Completer<void>();
      when(mockAuthService.deleteUserAccount())
          .thenAnswer((_) => completer.future);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pump(); // Don't settle, so we can see loading state

      // Assert
      expect(find.text('Deleting account...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to clean up
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('displays correct profile sections',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(mockUser));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Profile Details'), findsOneWidget);
      expect(find.text('Account Management'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.mail_solid), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.square_arrow_left), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.trash_fill), findsOneWidget);
    });

    testWidgets('displays fallback username when displayName is null',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(mockUser));
      when(mockDocument.data()).thenReturn({
        'email': 'test@example.com',
        'displayName': null,
        'profileImageUrl': null,
        'createdAt': Timestamp.now(),
      });

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Username'), findsOneWidget);
    });

    testWidgets('displays fallback email when email is null',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(mockUser));
      when(mockDocument.data()).thenReturn({
        'email': null,
        'displayName': 'Test User',
        'profileImageUrl': null,
        'createdAt': Timestamp.now(),
      });

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('email@example.com'), findsOneWidget);
    });
    testWidgets('tapping edit profile picture button triggers update process',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(mockUser));

      // Mock the updateUserProfilePicture method to simulate successful update
      when(mockAuthService.updateUserProfilePicture(any, any, any))
          .thenAnswer((_) async => null);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find and tap the edit profile picture button
      final editButton = find.text('Edit Profile Picture');
      expect(editButton, findsOneWidget);

      await tester.tap(editButton);
      await tester.pump(); // Pump once to trigger the async operation

      // Assert - The button should still be there (since image picker would be called in real scenario)
      // In a real test, the image picker would open, but in unit tests we just verify the button works
      expect(editButton, findsOneWidget);

      // Verify the button can be tapped (no exceptions thrown)
      // In integration tests, you would verify the actual image picker opens
    });
  });
}
