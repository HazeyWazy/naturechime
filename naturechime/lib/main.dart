import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:naturechime/screens/welcome_screen.dart';
import 'package:naturechime/services/auth_service.dart';
import 'package:naturechime/utils/theme.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    debugPrint(".env file loaded successfully.");
    debugPrint(
        "Attempting to read CLOUDINARY_CLOUD_NAME from main: ${dotenv.env['CLOUDINARY_CLOUD_NAME']}");
  } catch (e) {
    debugPrint("ERROR loading .env file in main: $e");
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService(),
        ),
      ],
      child: const NatureChimeApp(),
    ),
  );
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
