import 'package:flutter/material.dart';

final Color seedColor = const Color.fromRGBO(46, 139, 87, 1);

final lightColorScheme = ColorScheme.fromSeed(
  seedColor: seedColor,
  brightness: Brightness.light,
);

final darkColorScheme = ColorScheme.fromSeed(
  seedColor: seedColor,
  brightness: Brightness.dark,
);

final ThemeData natureChimeLightTheme = ThemeData().copyWith(
  colorScheme: lightColorScheme,
);

final ThemeData natureChimeDarkTheme = ThemeData().copyWith(
  colorScheme: darkColorScheme,
);
