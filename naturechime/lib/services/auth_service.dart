import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:naturechime/models/user_model.dart';

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
      "AuthService constructor: CLOUDINARY_PROFILE_UPLOAD_PRESET from .env = '$profileUploadPresetFromEnv'",
    );

    if (cloudNameFromEnv != null &&
        cloudNameFromEnv.isNotEmpty &&
        profileUploadPresetFromEnv != null &&
        profileUploadPresetFromEnv.isNotEmpty) {
      _cloudinaryCloudName = cloudNameFromEnv;
      _cloudinaryUnsignedUploadPreset = profileUploadPresetFromEnv;
      try {
        debugPrint(
          "AuthService constructor: Attempting to initialize CloudinaryPublic with CloudName: '$_cloudinaryCloudName', Preset: '$_cloudinaryUnsignedUploadPreset'",
        );
        _cloudinary = CloudinaryPublic(
          _cloudinaryCloudName!,
          _cloudinaryUnsignedUploadPreset!,
          cache: false,
        );
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

  // Update user profile picture
  Future<void> updateUserProfilePicture(
    String userId,
    File newImageFile,
    String? oldImageUrl,
  ) async {
    try {
      // Upload the new image
      String? newImageUrl = await _uploadImageToCloudinary(newImageFile);
      if (newImageUrl == null) {
        throw Exception("Failed to upload new profile image, URL was null.");
      }

      // Update Firestore with the new image URL
      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': newImageUrl,
      });

      // Notify listeners if you want UI to react immediately to this change
      // For example, if ProfileScreen is listening directly to UserModel changes from a stream.
      // However, since ProfileScreen fetches UserModel on init, this might not be needed
      // if the user is expected to refresh or if the screen re-fetches data.
      // For now, we are not calling notifyListeners() here as UserModel isn't directly managed by AuthService state.
      // notifyListeners(); // Consider if UserModel state should be propagated.
    } catch (e) {
      debugPrint("Error updating profile picture: $e");
      throw Exception("Failed to update profile picture: ${e.toString()}");
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

        // Create a UserModel instance
        final newUser = UserModel(
          uid: user.uid,
          email: email,
          displayName: displayName,
          profileImageUrl: profileImageUrl,
          createdAt: Timestamp.now(),
        );

        // Use the toFirestore method to convert the UserModel to a Map
        await _firestore.collection('users').doc(user.uid).set(newUser.toFirestore());
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

  // Delete user account (Firebase Auth user, then Firestore data)
  Future<void> deleteUserAccount() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("No user logged in to delete.");
    }

    final String userId = currentUser.uid;

    try {
      // Delete Firebase Auth user FIRST
      // This is the sensitive operation that might require recent sign-in.
      await currentUser.delete();
      debugPrint("User deleted from Firebase Auth for UID: $userId");

      // Step 2: If Auth deletion was successful, delete Firestore document
      await _firestore.collection('users').doc(userId).delete();
      debugPrint("User document deleted from Firestore for UID: $userId");

      // Step 3: (No-op) Attempt to delete Cloudinary image if Auth and Firestore deletion were successful
      // if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      //   await _deleteImageFromCloudinary(profileImageUrl);
      // }
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException during account deletion: ${e.code} - ${e.message}");
      if (e.code == 'requires-recent-login') {
        // IMPORTANT: Firestore document was NOT deleted if we are in this block.
        throw Exception(
            'This operation is sensitive and requires recent authentication. Please sign out and sign back in, then try deleting your account again.');
      }
      throw Exception("Failed to delete Firebase Auth user: ${e.message}");
    } catch (e) {
      debugPrint("Error deleting user account: ${e.toString()}");
      // Potentially, Firestore doc might not have been deleted if error occurred after Auth delete but before Firestore delete.
      // However, the primary goal is to ensure Auth delete is attempted first.
      throw Exception("An unexpected error occurred while deleting the account: ${e.toString()}");
    }
  }
}
