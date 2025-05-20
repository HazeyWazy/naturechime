import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScreenWrapper extends StatelessWidget {
  final Widget child;
  final Brightness? statusBarIconBrightness;

  const ScreenWrapper({
    super.key,
    required this.child,
    this.statusBarIconBrightness,
  });

  @override
  Widget build(BuildContext context) {
    final themeBrightness = Theme.of(context).brightness;
    final effectiveBrightness =
        statusBarIconBrightness ??
        (themeBrightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: effectiveBrightness,
        statusBarBrightness: effectiveBrightness,
      ),
      child: child,
    );
  }
}
