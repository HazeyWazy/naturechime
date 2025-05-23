import 'dart:math' as math;
import 'package:flutter/material.dart';

class AudioLevelIndicator extends StatelessWidget {
  final double audioLevel; // Between 0.0 and 1.0
  final int barCount;

  const AudioLevelIndicator({
    super.key,
    required this.audioLevel,
    this.barCount = 15,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const double interBarSpacing = 2.0;
    const double minBarHeightFactor = 0.05; // Minimum 5% height for any bar
    const double activeBarBaseHeightFactor = 0.1; // Min 10% height for an active bar

    return Container(
      height: 80, // Adjusted height
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate width available for bars themselves (after accounting for spacing)
          double availableWidthForBars = constraints.maxWidth - (barCount - 1) * interBarSpacing;
          if (availableWidthForBars < 0) availableWidthForBars = 0;

          double calculatedBarWidth = barCount > 0 ? availableWidthForBars / barCount : 0;
          // Ensure barWidth is at least 1.0px if possible, otherwise 0
          calculatedBarWidth = math.max(
              barCount > 0 && availableWidthForBars > barCount ? 1.0 : 0.0, calculatedBarWidth);

          if (calculatedBarWidth <= 0 && barCount > 0) {
            // Not enough space to draw any bars
            return Center(
              child: Text(
                '- - -',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            );
          }

          final activeBars = (audioLevel.clamp(0.0, 1.0) * barCount).round();
          List<Widget> barWidgets = [];

          for (int i = 0; i < barCount; i++) {
            final bool isActive = i < activeBars;

            double barHeightPercentage;
            if (!isActive) {
              barHeightPercentage = minBarHeightFactor;
            } else {
              // Active bars grow progressively taller
              final double progressiveFactor = (i + 1) / barCount;
              barHeightPercentage = activeBarBaseHeightFactor +
                  (progressiveFactor * (1.0 - activeBarBaseHeightFactor));
              barHeightPercentage = math.max(activeBarBaseHeightFactor, barHeightPercentage);
            }
            barHeightPercentage = barHeightPercentage.clamp(minBarHeightFactor, 1.0);

            Color barColor;
            if (!isActive) {
              barColor = colorScheme.onSurface.withValues(alpha: 0.25);
            } else {
              // Overall audio level determines the color palette shift
              if (audioLevel > 0.85 && (i + 1) / barCount > 0.75) {
                barColor = const Color.fromARGB(255, 255, 59, 48);
              } else if (audioLevel > 0.6 && (i + 1) / barCount > 0.5) {
                barColor = const Color.fromARGB(255, 255, 149, 0);
              } else {
                barColor = const Color.fromARGB(255, 52, 199, 89);
              }
            }

            barWidgets.add(
              Container(
                width: calculatedBarWidth,
                height: math.max(1.0, constraints.maxHeight * barHeightPercentage),
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: const BorderRadius.only(
                    // Rounded tops for bars
                    topLeft: Radius.circular(1.5),
                    topRight: Radius.circular(1.5),
                  ),
                ),
              ),
            );

            if (i < barCount - 1) {
              barWidgets.add(const SizedBox(width: interBarSpacing));
            }
          }

          return Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end, // Bars align at their bottom
              children: barWidgets,
            ),
          );
        },
      ),
    );
  }
}
