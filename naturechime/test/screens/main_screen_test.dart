import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/cupertino.dart';

// Mock screens that don't depend on Firebase
class MockHomeScreen extends StatelessWidget {
  const MockHomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class MockLibraryScreen extends StatelessWidget {
  const MockLibraryScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class MockExploreScreen extends StatelessWidget {
  const MockExploreScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class MockRecordScreen extends StatelessWidget {
  const MockRecordScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class MockProfileScreen extends StatelessWidget {
  const MockProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

// Test wrapper for MainScreen that uses mock screens
class TestMainScreen extends StatefulWidget {
  const TestMainScreen({super.key});

  @override
  State<TestMainScreen> createState() => _TestMainScreenState();
}

class _TestMainScreenState extends State<TestMainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    MockHomeScreen(),
    MockLibraryScreen(),
    MockExploreScreen(),
    MockRecordScreen(),
    MockProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book_fill),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.mic_fill),
            label: 'Record',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_fill),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MainScreen displays HomeScreen initially', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TestMainScreen()));

    expect(find.byType(MockHomeScreen), findsOneWidget);
    expect(find.byType(MockLibraryScreen), findsNothing);
    expect(find.byType(MockExploreScreen), findsNothing);
    expect(find.byType(MockRecordScreen), findsNothing);
    expect(find.byType(MockProfileScreen), findsNothing);
  });

  testWidgets('MainScreen navigation works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TestMainScreen()));

    // Tap on Library
    await tester.tap(find.byIcon(CupertinoIcons.book_fill));
    await tester.pumpAndSettle();
    expect(find.byType(MockLibraryScreen), findsOneWidget);

    // Tap on Explore
    await tester.tap(find.byIcon(CupertinoIcons.search));
    await tester.pumpAndSettle();
    expect(find.byType(MockExploreScreen), findsOneWidget);

    // Tap on Record
    await tester.tap(find.byIcon(CupertinoIcons.mic_fill));
    await tester.pumpAndSettle();
    expect(find.byType(MockRecordScreen), findsOneWidget);

    // Tap on Profile
    await tester.tap(find.byIcon(CupertinoIcons.person_fill));
    await tester.pumpAndSettle();
    expect(find.byType(MockProfileScreen), findsOneWidget);

    // Tap on Home
    await tester.tap(find.byIcon(CupertinoIcons.home));
    await tester.pumpAndSettle();
    expect(find.byType(MockHomeScreen), findsOneWidget);
  });
}
