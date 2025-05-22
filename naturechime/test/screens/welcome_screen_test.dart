import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturechime/screens/create_account_screen.dart';
import 'package:naturechime/screens/login_screen.dart';
import 'package:naturechime/screens/main_screen.dart';
import 'package:naturechime/screens/welcome_screen.dart';
import 'package:naturechime/widgets/custom_button.dart';

void main() {
  testWidgets('WelcomeScreen displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

    // Verify logo and title
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('NatureChime'), findsOneWidget);
    expect(find.text('Capture the world, one sound at a time'), findsOneWidget);

    // Verify feature boxes
    expect(find.text('Record Anywhere'), findsOneWidget);
    expect(find.text('Location Tagging'), findsOneWidget);
    expect(find.text('Discover Unique\nSoundscapes'), findsOneWidget);
    expect(find.text('Organise Your Sounds'), findsOneWidget);

    // Verify buttons
    expect(find.widgetWithText(CustomButton, 'Create Account'), findsOneWidget);
    expect(find.widgetWithText(CustomButton, 'Log In'), findsOneWidget);
    expect(find.text('Explore Without Account'), findsOneWidget);
  });

  testWidgets('WelcomeScreen navigates to Create Account screen', (WidgetTester tester) async {
    final heroController = HeroController();
    await tester.pumpWidget(
      MaterialApp(
        home: const WelcomeScreen(),
        navigatorObservers: [heroController],
      ),
    );

    final createAccountButtonFinder = find.widgetWithText(CustomButton, 'Create Account');
    await tester.ensureVisible(createAccountButtonFinder);
    await tester.pumpAndSettle(); // Ensure scrolling animation completes
    await tester.tap(createAccountButtonFinder);
    await tester.pumpAndSettle(); // Wait for navigation to complete

    expect(find.byType(CreateAccountScreen), findsOneWidget);
  });

  testWidgets('WelcomeScreen navigates to Log In screen', (WidgetTester tester) async {
    final heroController = HeroController();
    await tester.pumpWidget(
      MaterialApp(
        home: const WelcomeScreen(),
        navigatorObservers: [heroController],
      ),
    );

    final logInButtonFinder = find.widgetWithText(CustomButton, 'Log In');
    await tester.ensureVisible(logInButtonFinder);
    await tester.pumpAndSettle(); // Ensure scrolling animation completes
    await tester.tap(logInButtonFinder);
    await tester.pumpAndSettle(); // Wait for navigation to complete

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('WelcomeScreen navigates to MainScreen on explore', (WidgetTester tester) async {
    final heroController = HeroController();
    await tester.pumpWidget(
      MaterialApp(
        home: const WelcomeScreen(),
        navigatorObservers: [heroController],
      ),
    );

    final exploreButtonFinder = find.text('Explore Without Account');
    await tester.ensureVisible(exploreButtonFinder);
    await tester.pumpAndSettle(); // Ensure scrolling animation completes
    await tester.tap(exploreButtonFinder);
    await tester.pumpAndSettle(); // Wait for navigation to complete

    expect(find.byType(MainScreen), findsOneWidget);
  });
}
