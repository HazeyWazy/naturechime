import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturechime/screens/explore_screen.dart';
import 'package:naturechime/screens/home_screen.dart';
import 'package:naturechime/screens/library_screen.dart';
import 'package:naturechime/screens/main_screen.dart';
import 'package:naturechime/screens/profile_screen.dart';
import 'package:naturechime/screens/record_screen.dart';
import 'package:flutter/cupertino.dart';

void main() {
  testWidgets('MainScreen displays HomeScreen initially', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainScreen()));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(LibraryScreen), findsNothing);
    expect(find.byType(ExploreScreen), findsNothing);
    expect(find.byType(RecordScreen), findsNothing);
    expect(find.byType(ProfileScreen), findsNothing);
  });

  testWidgets('MainScreen navigation works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainScreen()));

    // Tap on Library
    await tester.tap(find.byIcon(CupertinoIcons.book_fill));
    await tester.pumpAndSettle();
    expect(find.byType(LibraryScreen), findsOneWidget);

    // Tap on Explore
    await tester.tap(find.byIcon(CupertinoIcons.search));
    await tester.pumpAndSettle();
    expect(find.byType(ExploreScreen), findsOneWidget);

    // Tap on Record
    await tester.tap(find.byIcon(CupertinoIcons.mic_fill));
    await tester.pumpAndSettle();
    expect(find.byType(RecordScreen), findsOneWidget);

    // Tap on Profile
    await tester.tap(find.byIcon(CupertinoIcons.person_fill));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);

    // Tap on Home
    await tester.tap(find.byIcon(CupertinoIcons.home));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
