import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturechime/widgets/custom_button.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('CustomButton', () {
    testWidgets('displays text correctly', (WidgetTester tester) async {
      const buttonText = 'Test Button';
      await tester.pumpWidget(buildTestWidget(
        CustomButton(text: buttonText, onPressed: () {}),
      ));

      expect(find.text(buttonText), findsOneWidget);
    });

    testWidgets('executes onPressed callback when enabled', (WidgetTester tester) async {
      int pressCount = 0;
      await tester.pumpWidget(buildTestWidget(
        CustomButton(
          text: 'Press Me',
          onPressed: () => pressCount++,
        ),
      ));

      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      expect(pressCount, 1);
    });

    testWidgets('has correct style properties', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        CustomButton(text: 'Styled Button', onPressed: () {}),
      ));

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      final style = button.style!;

      // Test specific style properties
      expect(style.shape?.resolve({}), isA<RoundedRectangleBorder>());
      expect((style.shape?.resolve({}) as RoundedRectangleBorder).borderRadius,
          BorderRadius.circular(12.0));

      // Test colors
      final backgroundColor = style.backgroundColor?.resolve({});
      expect(backgroundColor, isA<Color>());

      final foregroundColor = style.foregroundColor?.resolve({});
      expect(foregroundColor, isA<Color>());

      // Test border
      final side = style.side?.resolve({});
      expect(side, isA<BorderSide>());
      expect(side?.width, 2.0);
    });

    testWidgets('updates visual properties on interaction', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        CustomButton(text: 'Press Me', onPressed: () {}),
      ));

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      final style = button.style!;

      // Test overlay colors are defined for different states
      final overlayColor = style.overlayColor?.resolve({
        WidgetState.pressed,
      });
      expect(overlayColor, isNotNull);
    });
  });
}
