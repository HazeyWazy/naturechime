import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturechime/widgets/audio_level_indicator.dart';

void main() {
  Widget buildTestWidget(double audioLevel, {int? barCount}) {
    return MaterialApp(
      home: Scaffold(
        body: AudioLevelIndicator(
          audioLevel: audioLevel,
          barCount: barCount ?? 15,
        ),
      ),
    );
  }

  testWidgets('AudioLevelIndicator renders with correct number of bars',
      (WidgetTester tester) async {
    const barCount = 10;
    await tester.pumpWidget(buildTestWidget(0.5, barCount: barCount));

    // Find all bar containers (excluding spacing widgets)
    final barFinder = find.byWidgetPredicate(
      (widget) => widget is Container && widget.child == null,
    );

    expect(barFinder, findsNWidgets(barCount));
  });

  testWidgets('AudioLevelIndicator shows correct active bars based on audio level',
      (WidgetTester tester) async {
    const barCount = 10;
    const audioLevel = 0.5; // 50% level should activate half the bars
    await tester.pumpWidget(buildTestWidget(audioLevel, barCount: barCount));

    final containers = tester
        .widgetList<Container>(find.byType(Container))
        .where(
          (container) => container.child == null, // Only get the bar containers
        )
        .toList();

    // Check if approximately half the bars are active
    int activeBarCount = containers.where((container) {
      final BoxDecoration? decoration = container.decoration as BoxDecoration?;
      final Color? color = decoration?.color;

      bool isFullyOpaque = false;
      if (color != null && color.a == 1.0) {
        isFullyOpaque = true;
      }
      return isFullyOpaque;
    }).length;

    expect(activeBarCount, (barCount * audioLevel).round());
  });

  testWidgets('AudioLevelIndicator handles invalid audio levels gracefully',
      (WidgetTester tester) async {
    // Test with audio level > 1.0
    await tester.pumpWidget(buildTestWidget(1.5));
    expect(find.byType(AudioLevelIndicator), findsOneWidget);

    // Test with negative audio level
    await tester.pumpWidget(buildTestWidget(-0.5));
    expect(find.byType(AudioLevelIndicator), findsOneWidget);
  });

  testWidgets('AudioLevelIndicator shows different colors based on audio level',
      (WidgetTester tester) async {
    // Test high audio level (should show red bars)
    await tester.pumpWidget(buildTestWidget(0.9));

    final containers = tester
        .widgetList<Container>(find.byType(Container))
        .where(
          (container) => container.child == null,
        )
        .toList();

    bool hasRedBar = containers.any((container) {
      final decoration = container.decoration as BoxDecoration;
      final color = decoration.color!;
      return color == const Color.fromARGB(255, 255, 59, 48);
    });

    expect(hasRedBar, true);
  });
}
