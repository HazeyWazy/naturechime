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

    // Setup default stub for dispose, as it's a ChangeNotifier
    when(mockAuthService.dispose()).thenAnswer((_) async {});
  });

  Widget createLoginScreen() {
    return MaterialApp(
      home: ChangeNotifierProvider<AuthService>(
        create: (_) => mockAuthService,
        child: const LoginScreen(),
      ),
      navigatorObservers: [mockNavigatorObserver],
      routes: {
        '/createAccount': (context) => const CreateAccountScreen(),
      },
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
      // Ensure button is visible before tapping
      await tester.ensureVisible(signUpButtonFinder);
      await tester.pumpAndSettle(); // Wait for scroll animations

      await tester.tap(signUpButtonFinder);
      await tester.pumpAndSettle(); // Wait for navigation

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
      await tester.pump(); // Pump to process the error and update state

      expect(find.text('Your email or password is incorrect.'), findsOneWidget);
    });

    testWidgets('Forgot Password validates email before sending', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Find and fill the email TextField with invalid email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');
      await tester.pump(); // Ensure text field updates

      // Find and tap the forgot password button
      final forgotPasswordButton = find.widgetWithText(TextButton, 'Forgot Password?');
      expect(forgotPasswordButton, findsOneWidget);
      await tester.ensureVisible(forgotPasswordButton); // Ensure button is visible
      await tester.pumpAndSettle(); // Allow scroll animations to finish

      await tester.tap(forgotPasswordButton);

      // Pump to allow SnackBar to be processed and begin appearing.
      await tester.pump();
      // Pump and settle to ensure SnackBar animations complete and it's findable.
      await tester.pumpAndSettle();

      // Verify the service was not called
      verifyNever(mockAuthService.sendPasswordResetEmail(any));

      // Verify that the SnackBar validation error message is shown
      expect(find.text('Please enter a valid email for password reset.'), findsOneWidget);
    });
  });
}

class MockUser extends Mock implements User {
  @override
  String get uid => 'mockuid';
}
