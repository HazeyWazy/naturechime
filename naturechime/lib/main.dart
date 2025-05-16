import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:naturechime/screens/welcome_screen.dart';
import 'package:naturechime/utils/theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const NatureChimeApp());
}

class NatureChimeApp extends StatelessWidget {
  const NatureChimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NatureChime',
      theme: natureChimeLightTheme,
      darkTheme: natureChimeDarkTheme,
      home: const WelcomeScreen(),
    );
  }
}
