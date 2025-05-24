import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naturechime/screens/explore_screen.dart';
import 'package:naturechime/screens/home_screen.dart';
import 'package:naturechime/screens/library_screen.dart';
import 'package:naturechime/screens/profile_screen.dart';
import 'package:naturechime/screens/record_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    LibraryScreen(),
    ExploreScreen(),
    RecordScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: Image.asset('assets/images/naturechime_logo.png'),
        title: const Text('NatureChime'),
        titleSpacing: 0.0,
        toolbarHeight: kToolbarHeight + 15,
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
      ),
      body: SafeArea(
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
        selectedItemColor: colorScheme.onPrimary,
        unselectedItemColor: colorScheme.inversePrimary,
        backgroundColor: colorScheme.primary,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
