import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:naturechime/screens/create_account_screen.dart';
import 'package:naturechime/screens/login_screen.dart';
import 'package:naturechime/services/auth_service.dart';
import 'package:naturechime/widgets/custom_button.dart';
import 'package:naturechime/widgets/google_sign_in_button.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Mock Firebase User
class MockUser extends Mock implements User {
  @override
  String get uid => 'testUid';
  @override
  String? get email => 'test@example.com';
  @override
  String? get displayName => 'testUser';
}

// Custom mock for AuthService
class CustomMockAuthService extends Mock implements AuthService {
  final List<VoidCallback> _listeners = [];
  bool _isNameTakenResponse = false;
  User? _createUserResponse = MockUser();
  Exception? _createUserError;

  void setIsDisplayNameTaken(bool isTaken) {
    _isNameTakenResponse = isTaken;
  }

  void setCreateUserResponse(User? user) {
    _createUserResponse = user;
    _createUserError = null;
  }

  void setCreateUserError(Exception error) {
    _createUserError = error;
    _createUserResponse = null;
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  @override
  void notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  @override
  Future<bool> isDisplayNameTaken(String displayName) async {
    return _isNameTakenResponse;
  }

  @override
  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    dynamic profileImage,
  ) async {
    if (_createUserError != null) {
      throw _createUserError!;
    }
    return _createUserResponse;
  }
}

Widget createTestableWidget({required Widget child, AuthService? authService}) {
  final mockAuth = authService ?? CustomMockAuthService();

  return ChangeNotifierProvider<AuthService>.value(
    value: mockAuth,
    child: MaterialApp(
      home: child,
      routes: {
        '/login': (context) => const LoginScreen(),
      },
    ),
  );
}

// Use GenerateNiceMocks
@GenerateNiceMocks([MockSpec<AuthService>()])
void main() {
  late CustomMockAuthService mockAuthService;

  setUp(() {
    mockAuthService = CustomMockAuthService();
    // Default configuration for successful tests
    mockAuthService.setIsDisplayNameTaken(false);
    mockAuthService.setCreateUserResponse(MockUser());
  });

  // Finders by Key
  final usernameFieldFinder = find.byKey(const Key('usernameField'));
  final emailFieldFinder = find.byKey(const Key('emailField'));
  final passwordFieldFinder = find.byKey(const Key('passwordField'));
  final confirmPasswordFieldFinder = find.byKey(const Key('confirmPasswordField'));
  final createAccountButtonFinder = find.widgetWithText(CustomButton, 'Create Account');

  testWidgets('CreateAccountScreen has all required UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(child: const CreateAccountScreen()));

    expect(find.text('Create Your Account'), findsOneWidget);
    expect(find.text('Start capturing sounds around you'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.text('Upload Profile Picture'), findsOneWidget);
    expect(usernameFieldFinder, findsOneWidget);
    expect(find.text('This will be visible to other users.'), findsOneWidget);
    expect(emailFieldFinder, findsOneWidget);
    expect(passwordFieldFinder, findsOneWidget);
    expect(confirmPasswordFieldFinder, findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
    expect(find.text('I agree to the Terms of Service & Privacy Policy.'), findsOneWidget);
    expect(createAccountButtonFinder, findsOneWidget);
    expect(find.text('Or sign up with'), findsOneWidget);
    expect(find.byType(GoogleSignInButton), findsOneWidget);
    expect(find.text('Already have an account?'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Log In'), findsOneWidget);
  });

  group('Form Validation Tests', () {
    testWidgets('Shows error when username is empty', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const CreateAccountScreen()));
      await tester.ensureVisible(createAccountButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(createAccountButtonFinder);
      await tester.pumpAndSettle();

      final usernameFieldState = tester.state<FormFieldState<String>>(usernameFieldFinder);
      expect(usernameFieldState.errorText, 'Username cannot be empty');
    });

    testWidgets('Shows error when email is empty', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const CreateAccountScreen()));
      await tester.enterText(usernameFieldFinder, 'testuser');
      await tester.ensureVisible(createAccountButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(createAccountButtonFinder);
      await tester.pumpAndSettle();

      final emailFieldState = tester.state<FormFieldState<String>>(emailFieldFinder);
      expect(emailFieldState.errorText, 'Email cannot be empty');
    });

    testWidgets('Shows error when email is invalid', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const CreateAccountScreen()));
      await tester.enterText(usernameFieldFinder, 'testuser');
      await tester.enterText(emailFieldFinder, 'invalidemail');
      await tester.ensureVisible(createAccountButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(createAccountButtonFinder);
      await tester.pumpAndSettle();

      final emailFieldState = tester.state<FormFieldState<String>>(emailFieldFinder);
      expect(emailFieldState.errorText, 'Enter a valid email address');
    });

    testWidgets('Shows error when password is empty', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const CreateAccountScreen()));
      await tester.enterText(usernameFieldFinder, 'testuser');
      await tester.enterText(emailFieldFinder, 'test@example.com');
      await tester.ensureVisible(createAccountButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(createAccountButtonFinder);
      await tester.pumpAndSettle();

      final passwordFieldState = tester.state<FormFieldState<String>>(passwordFieldFinder);
      expect(passwordFieldState.errorText, 'Password cannot be empty');
    });

    testWidgets('Shows error when password is too short', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const CreateAccountScreen()));
      await tester.enterText(usernameFieldFinder, 'testuser');
      await tester.enterText(emailFieldFinder, 'test@example.com');
      await tester.enterText(passwordFieldFinder, '123');
      await tester.ensureVisible(createAccountButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(createAccountButtonFinder);
      await tester.pumpAndSettle();

      final passwordFieldState = tester.state<FormFieldState<String>>(passwordFieldFinder);
      expect(passwordFieldState.errorText, 'Password must be at least 6 characters long');
    });

    testWidgets('Shows error when confirm password is empty', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const CreateAccountScreen()));
      await tester.enterText(usernameFieldFinder, 'testuser');
      await tester.enterText(emailFieldFinder, 'test@example.com');
      await tester.enterText(passwordFieldFinder, 'password123');
      await tester.ensureVisible(createAccountButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(createAccountButtonFinder);
      await tester.pumpAndSettle();

      final confirmPasswordFieldState =
          tester.state<FormFieldState<String>>(confirmPasswordFieldFinder);
      expect(confirmPasswordFieldState.errorText, 'Confirm password cannot be empty');
    });

    testWidgets('Shows error when passwords do not match', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const CreateAccountScreen()));
      await tester.enterText(usernameFieldFinder, 'testuser');
      await tester.enterText(emailFieldFinder, 'test@example.com');
      await tester.enterText(passwordFieldFinder, 'password123');
      await tester.enterText(confirmPasswordFieldFinder, 'password456');
      await tester.ensureVisible(createAccountButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(createAccountButtonFinder);
      await tester.pumpAndSettle();

      final confirmPasswordFieldState =
          tester.state<FormFieldState<String>>(confirmPasswordFieldFinder);
      expect(confirmPasswordFieldState.errorText, 'Passwords do not match');
    });
  });

  testWidgets('Shows error if terms are not agreed', (WidgetTester tester) async {
    await tester.pumpWidget(
        createTestableWidget(child: const CreateAccountScreen(), authService: mockAuthService));

    await tester.enterText(usernameFieldFinder, 'testuser');
    await tester.enterText(emailFieldFinder, 'test@example.com');
    await tester.enterText(passwordFieldFinder, 'password123');
    await tester.enterText(confirmPasswordFieldFinder, 'password123');

    // Ensure the button is visible before tapping
    await tester.ensureVisible(createAccountButtonFinder);
    await tester.pumpAndSettle();

    await tester.tap(createAccountButtonFinder);
    await tester.pumpAndSettle(); // Wait for animations including SnackBar

    // Find the SnackBar and check its content
    final snackBarFinder = find.byType(SnackBar);
    expect(snackBarFinder, findsOneWidget);
    expect(find.descendant(of: snackBarFinder, matching: find.text('You must agree to the terms.')),
        findsOneWidget);

    // Ensure that the LoginScreen is not found
    expect(find.byType(LoginScreen), findsNothing);
  });

  group('Account Creation Logic', () {
    testWidgets('Successfully creates account and navigates to LoginScreen',
        (WidgetTester tester) async {
      // Create a simpler test case focused on the auth service
      await tester.pumpWidget(createTestableWidget(
        child: const CreateAccountScreen(),
        authService: mockAuthService,
      ));

      // Simple test to ensure checkbox and buttons can be found
      expect(find.byType(Checkbox), findsOneWidget);
      expect(createAccountButtonFinder, findsOneWidget);

      // Fill form fields with valid data
      await tester.enterText(usernameFieldFinder, 'testuser');
      await tester.enterText(emailFieldFinder, 'test@example.com');
      await tester.enterText(passwordFieldFinder, 'password123');
      await tester.enterText(confirmPasswordFieldFinder, 'password123');

      // Check form validation
      await tester.pump();
      expect(tester.state<FormFieldState<String>>(usernameFieldFinder).hasError, isFalse);
      expect(tester.state<FormFieldState<String>>(emailFieldFinder).hasError, isFalse);
      expect(tester.state<FormFieldState<String>>(passwordFieldFinder).hasError, isFalse);
      expect(tester.state<FormFieldState<String>>(confirmPasswordFieldFinder).hasError, isFalse);

      // Accept terms
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Before tapping, verify the button is correctly set up
      expect(createAccountButtonFinder, findsOneWidget);

      // Directly call the form validation and onPressed
      final FormState formState = tester.state(find.byType(Form));
      expect(formState, isNotNull);
      expect(formState.validate(), isTrue);

      // Tap the button
      await tester.ensureVisible(createAccountButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(createAccountButtonFinder);

      // Wait for all async operations and navigation to complete
      await tester.pumpAndSettle();

      // Check if the user was created and navigated to LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Shows error if username is taken', (WidgetTester tester) async {
      mockAuthService.setIsDisplayNameTaken(true);

      await tester.pumpWidget(
          createTestableWidget(child: const CreateAccountScreen(), authService: mockAuthService));

      await tester.enterText(usernameFieldFinder, 'existinguser');
      await tester.enterText(emailFieldFinder, 'test@example.com');
      await tester.enterText(passwordFieldFinder, 'password123');
      await tester.enterText(confirmPasswordFieldFinder, 'password123');

      // Ensure checkbox is visible before tapping
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Ensure button is visible before tapping
      await tester.ensureVisible(createAccountButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(createAccountButtonFinder, warnIfMissed: false);

      // Wait for SnackBar to appear
      await tester.pumpAndSettle();

      expect(find.text('Username is already taken.'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('Shows error on account creation failure', (WidgetTester tester) async {
      mockAuthService.setCreateUserError(FirebaseAuthException(
        code: 'test-error',
        message: 'A test error occurred.',
      ));

      await tester.pumpWidget(
          createTestableWidget(child: const CreateAccountScreen(), authService: mockAuthService));

      await tester.enterText(usernameFieldFinder, 'testuser');
      await tester.enterText(emailFieldFinder, 'test@example.com');
      await tester.enterText(passwordFieldFinder, 'password123');
      await tester.enterText(confirmPasswordFieldFinder, 'password123');

      // Ensure checkbox is visible before tapping
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Ensure button is visible before tapping
      await tester.ensureVisible(createAccountButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(createAccountButtonFinder, warnIfMissed: false);

      // Wait for SnackBar to appear
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to create account:'), findsOneWidget);
      expect(find.textContaining('A test error occurred.'), findsOneWidget);
    });

    testWidgets('Account creation shows message if user is null but no error',
        (WidgetTester tester) async {
      mockAuthService.setIsDisplayNameTaken(false);
      mockAuthService.setCreateUserResponse(null); // Explicitly return null user

      await tester.pumpWidget(
          createTestableWidget(child: const CreateAccountScreen(), authService: mockAuthService));

      await tester.enterText(usernameFieldFinder, 'testuser');
      await tester.enterText(emailFieldFinder, 'test@example.com');
      await tester.enterText(passwordFieldFinder, 'password123');
      await tester.enterText(confirmPasswordFieldFinder, 'password123');

      // Ensure checkbox is visible before tapping
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Ensure button is visible before tapping
      await tester.ensureVisible(createAccountButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(createAccountButtonFinder, warnIfMissed: false);

      // Wait for SnackBar to appear
      await tester.pumpAndSettle();

      expect(find.text('Account creation completed, but no user data returned.'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing); // Should not navigate
    });
  });

  testWidgets('Password visibility toggle works for password field', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(child: const CreateAccountScreen()));

    // Check initial state (obscured)
    final initialPasswordEditableTextFinder = find.descendant(
      of: passwordFieldFinder,
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(initialPasswordEditableTextFinder).obscureText, isTrue);

    // Make sure visibility icon is visible before tapping
    final visibilityIconFinder =
        find.descendant(of: passwordFieldFinder, matching: find.byIcon(Icons.visibility_off));
    await tester.ensureVisible(visibilityIconFinder);
    await tester.pumpAndSettle();

    // Tap to make visible
    await tester.tap(visibilityIconFinder, warnIfMissed: false);
    await tester.pumpAndSettle();

    final visiblePasswordEditableTextFinder = find.descendant(
      of: passwordFieldFinder,
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(visiblePasswordEditableTextFinder).obscureText, isFalse);
    expect(find.descendant(of: passwordFieldFinder, matching: find.byIcon(Icons.visibility)),
        findsOneWidget);

    // Make sure visibility icon is visible before tapping again
    final visibilityOnIconFinder =
        find.descendant(of: passwordFieldFinder, matching: find.byIcon(Icons.visibility));
    await tester.ensureVisible(visibilityOnIconFinder);
    await tester.pumpAndSettle();

    // Tap to make obscure again
    await tester.tap(visibilityOnIconFinder, warnIfMissed: false);
    await tester.pumpAndSettle();

    final obscuredPasswordEditableTextFinder = find.descendant(
      of: passwordFieldFinder,
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(obscuredPasswordEditableTextFinder).obscureText, isTrue);
    expect(find.descendant(of: passwordFieldFinder, matching: find.byIcon(Icons.visibility_off)),
        findsOneWidget);
  });

  testWidgets('Password visibility toggle works for confirm password field',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(child: const CreateAccountScreen()));

    final initialConfirmPasswordEditableTextFinder = find.descendant(
      of: confirmPasswordFieldFinder,
      matching: find.byType(EditableText),
    );
    expect(
        tester.widget<EditableText>(initialConfirmPasswordEditableTextFinder).obscureText, isTrue);

    // Make sure visibility icon is visible before tapping
    final visibilityIconFinder = find.descendant(
        of: confirmPasswordFieldFinder, matching: find.byIcon(Icons.visibility_off));
    await tester.ensureVisible(visibilityIconFinder);
    await tester.pumpAndSettle();

    await tester.tap(visibilityIconFinder, warnIfMissed: false);
    await tester.pumpAndSettle();

    final visibleConfirmPasswordEditableTextFinder = find.descendant(
      of: confirmPasswordFieldFinder,
      matching: find.byType(EditableText),
    );
    expect(
        tester.widget<EditableText>(visibleConfirmPasswordEditableTextFinder).obscureText, isFalse);
    expect(find.descendant(of: confirmPasswordFieldFinder, matching: find.byIcon(Icons.visibility)),
        findsOneWidget);

    // Make sure visibility on icon is visible before tapping again
    final visibilityOnIconFinder =
        find.descendant(of: confirmPasswordFieldFinder, matching: find.byIcon(Icons.visibility));
    await tester.ensureVisible(visibilityOnIconFinder);
    await tester.pumpAndSettle();

    await tester.tap(visibilityOnIconFinder, warnIfMissed: false);
    await tester.pumpAndSettle();

    final obscuredConfirmPasswordEditableTextFinder = find.descendant(
      of: confirmPasswordFieldFinder,
      matching: find.byType(EditableText),
    );
    expect(
        tester.widget<EditableText>(obscuredConfirmPasswordEditableTextFinder).obscureText, isTrue);
    expect(
        find.descendant(
            of: confirmPasswordFieldFinder, matching: find.byIcon(Icons.visibility_off)),
        findsOneWidget);
  });

  testWidgets('Tapping "Log In" navigates to LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(child: const CreateAccountScreen()));

    // Find the Log In button
    final logInButton = find.widgetWithText(TextButton, 'Log In');

    // Ensure button is visible before tapping
    await tester.ensureVisible(logInButton);
    await tester.pumpAndSettle();

    await tester.tap(logInButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Profile picture upload button is present', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(child: const CreateAccountScreen()));
    expect(find.text('Upload Profile Picture'), findsOneWidget);
  });
}
