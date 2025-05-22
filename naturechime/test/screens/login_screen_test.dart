import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturechime/screens/create_account_screen.dart';
import 'package:naturechime/screens/login_screen.dart';
import 'package:naturechime/widgets/custom_button.dart';
import 'package:naturechime/widgets/google_sign_in_button.dart';
import 'package:provider/provider.dart';
import 'package:naturechime/services/auth_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Generate mocks for AuthService and NavigatorObserver
@GenerateNiceMocks([MockSpec<NavigatorObserver>()])
@GenerateMocks([AuthService])
import 'login_screen_test.mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockAuthService = MockAuthService();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  Widget createLoginScreen() {
    return Provider<AuthService>.value(
      value: mockAuthService,
      child: MaterialApp(
        home: const LoginScreen(),
        navigatorObservers: [mockNavigatorObserver],
        routes: {
          '/createAccount': (context) => const CreateAccountScreen(),
        },
      ),
    );
  }

  group('LoginScreen UI and Validation Tests', () {
    testWidgets('UI elements are present', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Verify TextFormFields for email and password
      expect(find.byType(TextFormField), findsNWidgets(2));

      // Verify 'Log In' button
      expect(find.widgetWithText(CustomButton, 'Log In'), findsOneWidget);

      // Verify 'Forgot Password?' button
      expect(find.widgetWithText(TextButton, 'Forgot Password?'), findsOneWidget);

      // Verify Google Sign In Button
      expect(find.byType(GoogleSignInButton), findsOneWidget);

      // Verify 'Sign up' button
      expect(find.widgetWithText(TextButton, 'Sign up'), findsOneWidget);
    });

    testWidgets('Shows error for empty email and password', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      await tester.tap(find.widgetWithText(CustomButton, 'Log In'));
      await tester.pump();

      expect(find.text('Email cannot be empty'), findsOneWidget);
      expect(find.text('Password too short'), findsOneWidget);
    });

    testWidgets('Shows error for invalid email format', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      await tester.enterText(find.byType(TextFormField).first, 'invalidemail');
      await tester.tap(find.widgetWithText(CustomButton, 'Log In'));
      await tester.pump();

      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('Shows error for password too short', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, '123');
      await tester.tap(find.widgetWithText(CustomButton, 'Log In'));
      await tester.pump();

      expect(find.text('Password too short'), findsOneWidget);
    });
  });

  group('LoginScreen Navigation and Auth Logic Tests', () {
    testWidgets('Tapping Sign up navigates to CreateAccountScreen', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      final signUpButtonFinder = find.widgetWithText(TextButton, 'Sign up');
      await tester.ensureVisible(signUpButtonFinder); // Scroll to the button
      await tester.pumpAndSettle(); // Wait for scroll to finish

      await tester.tap(signUpButtonFinder);
      await tester.pump(); // Process the tap
      await tester.pump(const Duration(milliseconds: 300)); // Allow time for initial frame of new screen
      await tester.pumpAndSettle(); // Then settle fully

      expect(find.byType(CreateAccountScreen), findsOneWidget);
      verify(mockNavigatorObserver.didPush(any, any));
    });

    testWidgets('Successful login navigates to MainScreen', (WidgetTester tester) async {
      when(mockAuthService.signInWithEmailAndPassword(any, any))
          .thenAnswer((_) async => MockUser());

      await tester.pumpWidget(createLoginScreen());

      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.widgetWithText(CustomButton, 'Log In'));
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPush(any, any));
    });

    testWidgets('Failed login shows error message', (WidgetTester tester) async {
      when(mockAuthService.signInWithEmailAndPassword(any, any))
          .thenThrow(Exception('Login Failed'));

      await tester.pumpWidget(createLoginScreen());

      await tester.enterText(find.byType(TextFormField).first, 'wrong@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'wrongpassword');
      await tester.tap(find.widgetWithText(CustomButton, 'Log In'));
      await tester.pump();

      expect(find.text('Your email or password is incorrect.'), findsOneWidget);
    });

    testWidgets('Forgot Password shows snackbar on success', (WidgetTester tester) async {
      when(mockAuthService.sendPasswordResetEmail(any))
          .thenAnswer((_) async {}); // Return a completed future

      await tester.pumpWidget(createLoginScreen());

      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.widgetWithText(TextButton, 'Forgot Password?'));
      await tester.pumpAndSettle(); // Use pumpAndSettle to wait for SnackBar

      expect(find.text('Password reset email sent.'), findsOneWidget);
    });

    testWidgets('Forgot Password shows error snackbar on failure', (WidgetTester tester) async {
      when(mockAuthService.sendPasswordResetEmail(any)).thenThrow(Exception('Error sending email'));

      await tester.pumpWidget(createLoginScreen());

      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.widgetWithText(TextButton, 'Forgot Password?'));
      await tester.pumpAndSettle(); // Use pumpAndSettle to wait for SnackBar

      expect(find.text('Error: Exception: Error sending email'), findsOneWidget);
    });
  });
}

class MockUser extends Mock implements User {
  @override
  String get uid => 'mockuid';
}
