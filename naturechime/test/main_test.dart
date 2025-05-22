import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturechime/main.dart';
import 'package:naturechime/screens/main_screen.dart';

void main() {
  testWidgets('NatureChimeApp builds correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NatureChimeApp());

    // Verify that the MainScreen is present.
    expect(find.byType(MainScreen), findsOneWidget);

    // Verify that MaterialApp is configured correctly.
    final MaterialApp materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'NatureChime');
    expect(materialApp.debugShowCheckedModeBanner, false);
  });
}
