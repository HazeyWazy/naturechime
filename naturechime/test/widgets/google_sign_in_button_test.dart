import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:naturechime/services/auth_service.dart';
import 'package:naturechime/widgets/google_sign_in_button.dart';
import 'package:mockito/mockito.dart';

// Mock classes
class MockAuthService extends Mock implements AuthService {
  @override
  Future<User?> signInWithGoogle() => super.noSuchMethod(
        Invocation.method(#signInWithGoogle, []),
        returnValue: Future.value(null),
      );
}

class MockUser extends Mock implements User {
  @override
  String toString() => 'MockUser';
}

void main() {
  late MockAuthService mockAuthService;
  late MockUser mockUser;

  setUp(() {
    mockAuthService = MockAuthService();
    mockUser = MockUser();
  });

  Widget buildTestWidget({VoidCallback? onSuccess}) {
    return MaterialApp(
      home: ChangeNotifierProvider<AuthService>.value(
        value: mockAuthService,
        child: Scaffold(
          body: GoogleSignInButton(
            onSuccess: onSuccess,
          ),
        ),
      ),
    );
  }

  group('GoogleSignInButton', () {
    testWidgets('displays correct initial state', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('executes onSuccess callback after successful sign in', (WidgetTester tester) async {
      bool onSuccessCalled = false;
      when(mockAuthService.signInWithGoogle())
          .thenAnswer((_) => Future.value(mockUser));

      await tester.pumpWidget(buildTestWidget(
        onSuccess: () => onSuccessCalled = true,
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(onSuccessCalled, isTrue);
    });

    testWidgets('shows error message on sign in failure', (WidgetTester tester) async {
      when(mockAuthService.signInWithGoogle())
          .thenAnswer((_) => Future.error('Sign in failed'));

      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Google sign-in failed: Sign in failed'), findsOneWidget);
    });
  });
}

