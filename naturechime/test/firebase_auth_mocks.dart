import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> setupFirebaseAuthMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebasePlatform.instance = MockFirebasePlatform();
  // Initialize a mock Firebase app
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'testApiKey',
      appId: 'testAppId',
      messagingSenderId: 'testSenderId',
      projectId: 'testProjectId',
    ),
  );
}

class MockFirebasePlatform extends FirebasePlatform {
  MockFirebasePlatform() : super();

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return MockFirebaseAppPlatform(name: name, options: options);
  }

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return MockFirebaseAppPlatform(
      name: name,
      options: const FirebaseOptions(
        apiKey: 'testApiKey',
        appId: 'testAppId',
        messagingSenderId: 'testSenderId',
        projectId: 'testProjectId',
      ),
    );
  }
}

/// Mock implementation of FirebaseAppPlatform.
class MockFirebaseAppPlatform extends FirebaseAppPlatform {
  MockFirebaseAppPlatform({
    String? name,
    FirebaseOptions? options,
  }) : super(
          name ?? defaultFirebaseAppName,
          options ??
              const FirebaseOptions(
                apiKey: 'testApiKey',
                appId: 'testAppId',
                messagingSenderId: 'testSenderId',
                projectId: 'testProjectId',
              ),
        );
}
