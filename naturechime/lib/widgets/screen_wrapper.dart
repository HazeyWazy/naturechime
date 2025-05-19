import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScreenWrapper extends StatelessWidget {
  final Widget child;
  final bool autoStatusBarBrightness;

  const ScreenWrapper({
    super.key,
    required this.child,
    this.autoStatusBarBrightness = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final statusBarBrightness =
        autoStatusBarBrightness
            ? (isDarkMode ? Brightness.light : Brightness.dark)
            : Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: statusBarBrightness,
        statusBarBrightness: statusBarBrightness,
      ),
      child: child,
    );
  }
}
