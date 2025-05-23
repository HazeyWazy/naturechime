import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cloudinary credentials will be loaded from .env
  late final String? _cloudinaryCloudName;
  late final String? _cloudinaryUnsignedUploadPreset;
  CloudinaryPublic? _cloudinary;

  AuthService() {
    debugPrint("AuthService constructor: Attempting to load Cloudinary .env variables.");
    final String? cloudNameFromEnv = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final String? profileUploadPresetFromEnv = dotenv.env['CLOUDINARY_PROFILE_UPLOAD_PRESET'];

    debugPrint("AuthService constructor: CLOUDINARY_CLOUD_NAME from .env = '$cloudNameFromEnv'");
    debugPrint(
        "AuthService constructor: CLOUDINARY_PROFILE_UPLOAD_PRESET from .env = '$profileUploadPresetFromEnv'");

    if (cloudNameFromEnv != null &&
        cloudNameFromEnv.isNotEmpty &&
        profileUploadPresetFromEnv != null &&
        profileUploadPresetFromEnv.isNotEmpty) {
      _cloudinaryCloudName = cloudNameFromEnv;
      _cloudinaryUnsignedUploadPreset = profileUploadPresetFromEnv;
      try {
        debugPrint(
            "AuthService constructor: Attempting to initialize CloudinaryPublic with CloudName: '$_cloudinaryCloudName', Preset: '$_cloudinaryUnsignedUploadPreset'");
        _cloudinary =
            CloudinaryPublic(_cloudinaryCloudName!, _cloudinaryUnsignedUploadPreset!, cache: false);
        debugPrint("AuthService constructor: Cloudinary client initialized successfully.");
      } catch (e) {
        _cloudinary = null; // Ensure it's null if constructor fails
        debugPrint("AuthService constructor: ERROR initializing CloudinaryPublic: $e");
      }
    } else {
      _cloudinaryCloudName = null;
      _cloudinaryUnsignedUploadPreset = null;
      _cloudinary = null;
      debugPrint(
          "AuthService constructor: CRITICAL - Cloudinary Cloud Name or Profile Upload Preset is not set or is empty in .env. Profile image uploads disabled.");
    }
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    if (_cloudinary == null) {
      debugPrint(
          "AuthService _uploadImageToCloudinary: Cloudinary client not initialized. Check .env configuration.");
      throw Exception('Cloudinary credentials not configured in .env for AuthService.');
    }
    try {
      CloudinaryResponse response = await _cloudinary!.uploadFile(
        CloudinaryFile.fromFile(imageFile.path, resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Sign in with email & password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Forgot Password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      const String webClientId =
          '58487502056-9serb37gaqh2srep4c4beu2e4i65i3ju.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: webClientId,
      );

      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Firebase Auth error: ${e.message}');
    } on PlatformException {
      throw Exception('Google Sign-In platform error.');
    } catch (e) {
      throw Exception('An unexpected error occurred during Google Sign-In.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Create account with email, password, displayName, and profile image
  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    File? profileImageFile,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        String profileImageUrl = ''; // Default to empty string

        if (profileImageFile != null) {
          // Upload to Cloudinary
          String? cloudinaryUrl = await _uploadImageToCloudinary(profileImageFile);
          if (cloudinaryUrl != null) {
            profileImageUrl = cloudinaryUrl;
          } else {
            debugPrint(
                'Cloudinary upload returned null, though an exception should have been thrown.');
          }
        }

        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'displayName': displayName,
          'profileImageUrl': profileImageUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during account creation: ${e.toString()}');
    }
  }

  // Check if username is already in use
  Future<bool> isDisplayNameTaken(String displayName) async {
    final querySnapshot =
        await _firestore.collection('users').where('displayName', isEqualTo: displayName).get();

    return querySnapshot.docs.isNotEmpty;
  }
}
