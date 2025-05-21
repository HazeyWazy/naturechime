import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _cloudinaryCloudName = 'dogct8rpj';
  static const String _cloudinaryUnsignedUploadPreset = 'NCProfilePics';

  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    _cloudinaryCloudName,
    _cloudinaryUnsignedUploadPreset,
    cache: false,
  );

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
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
    } on PlatformException catch (e) {
      throw Exception('Google Sign-In platform error: ${e.message}');
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
            throw Exception('Failed to upload profile image.');
          }
        }

        try {
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': email,
            'displayName': displayName,
            'profileImageUrl': profileImageUrl, // Store Cloudinary URL or empty
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          throw Exception('Failed to save user details after account creation.');
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during account creation.');
    }
  }

  // Check if username is already in use
  Future<bool> isDisplayNameTaken(String displayName) async {
    final querySnapshot =
        await _firestore.collection('users').where('displayName', isEqualTo: displayName).get();

    return querySnapshot.docs.isNotEmpty;
  }
}
