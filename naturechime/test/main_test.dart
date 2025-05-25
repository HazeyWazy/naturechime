import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:naturechime/main.dart';
import 'package:naturechime/screens/main_screen.dart';
import 'package:naturechime/screens/welcome_screen.dart';
import 'package:naturechime/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'firebase_auth_mocks.dart' as firebase_mocks; // Import the new mock setup

// Mock AuthService
class MockAuthService extends Mock implements AuthService {}

void main() {
  setUpAll(() async {
    // Use the new mock setup for Firebase
    await firebase_mocks.setupFirebaseAuthMocksAndGetApp();
  });

  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<AuthService>.value(
      value: mockAuthService,
      child: const NatureChimeApp(),
    );
  }

  testWidgets('NatureChimeApp navigates to WelcomeScreen when user is null',
      (WidgetTester tester) async {
    // Arrange
    when(mockAuthService.currentUser).thenReturn(null);

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); // Allow time for navigation

    // Assert
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(MainScreen), findsNothing);

    final MaterialApp materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'NatureChime');
    expect(materialApp.debugShowCheckedModeBanner, false);
  });

  testWidgets('NatureChimeApp navigates to MainScreen when user is not null',
      (WidgetTester tester) async {
    // Arrange
    // Use MockUser from firebase_auth_mocks
    final mockUser = MockUser(
      isAnonymous: false,
      uid: 'someuid',
      email: 'test@example.com',
      displayName: 'Test User',
    );
    when(mockAuthService.currentUser).thenReturn(mockUser);

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); // Allow time for navigation

    // Assert
    expect(find.byType(MainScreen), findsOneWidget);
    expect(find.byType(WelcomeScreen), findsNothing);

    final MaterialApp materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'NatureChime');
    expect(materialApp.debugShowCheckedModeBanner, false);
  });
}
