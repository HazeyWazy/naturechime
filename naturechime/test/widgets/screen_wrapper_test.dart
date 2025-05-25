import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturechime/widgets/screen_wrapper.dart';

void main() {
  testWidgets('ScreenWrapper displays its child widget',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ScreenWrapper(
          child: Text('Test Child'),
        ),
      ),
    );

    expect(find.text('Test Child'), findsOneWidget);
  });

  testWidgets('ScreenWrapper uses default brightness based on theme',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: ScreenWrapper(
          child: Container(),
        ),
      ),
    );

    final AnnotatedRegion<SystemUiOverlayStyle> annotatedRegion =
        tester.widget(find.byType(AnnotatedRegion<SystemUiOverlayStyle>));
    expect(
        annotatedRegion.value.statusBarIconBrightness, equals(Brightness.dark));
  });

  testWidgets('ScreenWrapper respects custom statusBarIconBrightness',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenWrapper(
        statusBarIconBrightness: Brightness.light,
        child: Container(),
      ),
    );

    final AnnotatedRegion<SystemUiOverlayStyle> annotatedRegion =
        tester.widget(find.byType(AnnotatedRegion<SystemUiOverlayStyle>));
    expect(annotatedRegion.value.statusBarIconBrightness,
        equals(Brightness.light));
  });

  testWidgets('ScreenWrapper sets transparent status bar color',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenWrapper(
        child: Container(),
      ),
    );

    final AnnotatedRegion<SystemUiOverlayStyle> annotatedRegion =
        tester.widget(find.byType(AnnotatedRegion<SystemUiOverlayStyle>));
    expect(annotatedRegion.value.statusBarColor, equals(Colors.transparent));
  });
}
