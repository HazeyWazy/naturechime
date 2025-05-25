import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naturechime/screens/login_screen.dart';
import 'package:naturechime/screens/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:naturechime/models/user_model.dart';
import 'package:naturechime/services/auth_service.dart';

// Test helper class to mock Firestore
class TestFirestore {
  static FirebaseFirestore? _instance;
  static void setInstance(FirebaseFirestore instance) {
    _instance = instance;
  }

  static FirebaseFirestore get instance {
    return _instance ?? FirebaseFirestore.instance;
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _userModel;
  bool _isLoading = true;
  bool _isUpdatingPicture = false; // For loading indicator during picture update
  bool _isDeletingAccount = false; // For loading indicator during account deletion

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    // Ensure context is valid and widget is mounted before proceeding
    if (!mounted) return;
    setState(() {
      _isLoading = true; // Set loading true at the start of fetching
    });

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final User? currentUser = await authService.authStateChanges.first;

      if (!mounted) return; // Check again after async gap

      if (currentUser != null) {
        final userDocSnapshot =
            await TestFirestore.instance.collection('users').doc(currentUser.uid).get();

        if (!mounted) return; // Check again after async gap

        if (userDocSnapshot.exists) {
          setState(() {
            // Ensure the snapshot is cast to the type expected by UserModel.fromFirestore
            _userModel =
                UserModel.fromFirestore(userDocSnapshot as DocumentSnapshot<Map<String, dynamic>>);
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          debugPrint("User document not found in Firestore for UID: ${currentUser.uid}");
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        debugPrint("User not logged in when _fetchUserData was called.");
      }
    } catch (e, s) {
      debugPrint("Error in _fetchUserData: $e\n$s");
      if (mounted) {
        setState(() {
          _isLoading = false; // Ensure loading stops on error
        });
      }
    }
  }

  Future<void> _pickAndUpdateProfilePicture() async {
    if (!mounted || _userModel == null) return;

    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        if (!mounted) return;
        setState(() {
          _isUpdatingPicture = true;
        });

        final authService = Provider.of<AuthService>(context, listen: false);
        final User? currentUser = FirebaseAuth.instance.currentUser; // Get current Firebase user

        if (currentUser == null) {
          if (mounted) {
            setState(() {
              _isUpdatingPicture = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User not logged in. Cannot update picture.')),
            );
          }
          return;
        }

        await authService.updateUserProfilePicture(
          currentUser.uid, // Use UID from current Firebase user
          File(image.path),
          _userModel!.profileImageUrl, // Pass the old image URL
        );

        // Refresh user data to show the new picture
        await _fetchUserData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully!')),
          );
        }
      } else {
        // User cancelled the picker
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No image selected.')),
          );
        }
      }
    } catch (e, s) {
      debugPrint("Error picking/updating profile picture: $e\n$s");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile picture: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingPicture = false;
        });
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    if (!mounted) return;

    final bool? confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently lost.'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false); // Not confirmed
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              Navigator.of(context).pop(true); // Confirmed
            },
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      setState(() {
        _isDeletingAccount = true;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      try {
        await authService.deleteUserAccount();
        if (!mounted) return;
        // Navigate to Welcome Screen and show success message
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (context) => const WelcomeScreen()),
          (Route<dynamic> route) => false, // Remove all routes
        );
        // Show SnackBar on the WelcomeScreen (or use a global SnackBar service if available)
        // For simplicity, we assume WelcomeScreen can show it or we just log it.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully.')),
        );
      } catch (e, s) {
        debugPrint("Error deleting account: $e\n$s");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete account: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isDeletingAccount = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: StreamBuilder<User?>(
        stream: authService.authStateChanges,
        builder: (context, snapshot) {
          final firebaseUser = snapshot.data;

          if (snapshot.connectionState == ConnectionState.waiting ||
              _isLoading ||
              _isUpdatingPicture ||
              _isDeletingAccount) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                if (_isUpdatingPicture)
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text("Updating picture..."),
                  ),
                if (_isDeletingAccount)
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text("Deleting account..."),
                  ),
              ],
            ));
          }

          if (!snapshot.hasData || firebaseUser == null || _userModel == null) {
            // Handle not logged in state
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not logged in or user data not found.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    child: const Text('Go to Login'),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        CupertinoPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  )
                ],
              ),
            );
          }

          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Profile',
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: colorScheme.surfaceContainerHighest,
                              backgroundImage: _userModel?.profileImageUrl != null &&
                                      _userModel!.profileImageUrl!.isNotEmpty
                                  ? NetworkImage(_userModel!.profileImageUrl!)
                                  : null,
                              child: _userModel?.profileImageUrl == null ||
                                      _userModel!.profileImageUrl!.isEmpty
                                  ? Icon(
                                      CupertinoIcons.person_fill,
                                      size: 65,
                                      color: colorScheme.onSurface.withAlpha(75),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _userModel?.displayName ?? 'Username',
                              style: textTheme.titleLarge?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              icon: _isUpdatingPicture
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Icon(CupertinoIcons.pencil),
                              label: const Text('Edit Profile Picture'),
                              onPressed: _isUpdatingPicture ? null : _pickAndUpdateProfilePicture,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.secondary,
                                foregroundColor: colorScheme.onSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Profile Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: Icon(
                          CupertinoIcons.mail_solid,
                          color: colorScheme.onSurface,
                        ),
                        title: Text(
                          _userModel?.email ?? 'email@example.com',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Account Management',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(CupertinoIcons.square_arrow_left),
                          label: const Text('Logout'),
                          onPressed: () async {
                            await authService.signOut();
                            if (context.mounted) {
                              Navigator.of(context).pushReplacement(
                                CupertinoPageRoute(
                                  builder: (context) => const WelcomeScreen(),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            foregroundColor: colorScheme.onSurfaceVariant,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(CupertinoIcons.trash_fill),
                          label: const Text('Delete Account'),
                          onPressed: _isDeletingAccount ? null : _confirmDeleteAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.error,
                            foregroundColor: colorScheme.onError,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
