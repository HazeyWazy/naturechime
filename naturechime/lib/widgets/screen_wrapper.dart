import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScreenWrapper extends StatelessWidget {
  final Widget child;
  final Brightness statusBarIconBrightness;

  const ScreenWrapper({
    super.key,
    required this.child,
    this.statusBarIconBrightness = Brightness.dark,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: statusBarIconBrightness,
        statusBarBrightness: statusBarIconBrightness,
      ),
      child: child,
    );
  }
}
