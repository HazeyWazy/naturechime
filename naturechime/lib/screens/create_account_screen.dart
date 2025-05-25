import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naturechime/screens/login_screen.dart';
import 'package:naturechime/widgets/custom_button.dart';
import 'package:naturechime/widgets/google_sign_in_button.dart';
import 'package:naturechime/widgets/screen_wrapper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:naturechime/services/auth_service.dart';
import 'package:naturechime/utils/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

final ImagePicker _picker = ImagePicker();

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  File? _profileImageFile;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'Create Your Account',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Start capturing sounds around you',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Profile Picture Section
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            child: _profileImageFile == null
                                ? Icon(
                                    Icons.person,
                                    size: 65,
                                    color: colorScheme.onSurface.withAlpha(75),
                                  )
                                : ClipOval(
                                    child: Image.file(
                                      _profileImageFile!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 8),

                          // Upload Profile Picture Button
                          TextButton.icon(
                            onPressed: () async {
                              final pickedFile =
                                  await _picker.pickImage(source: ImageSource.gallery);
                              if (pickedFile != null) {
                                setState(() {
                                  _profileImageFile = File(pickedFile.path);
                                });
                              }
                            },
                            icon: Icon(
                              Icons.file_upload_outlined,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                            label: Text(
                              'Upload Profile Picture',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.primary,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(6),
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Username Field
                          Text(
                            'Username',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            key: const Key('usernameField'),
                            controller: _usernameController,
                            decoration: InputDecoration(
                              hintText: 'Choose a username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            style: TextStyle(
                              color: colorScheme.onSurface,
                            ),
                            validator: (value) => validateNonEmpty(value, 'Username'),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'This will be visible to other users. You cannot change it later.',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(alpha: 0.9),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Email Field
                          Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            key: const Key('emailField'),
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'example@gmail.com',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            style: TextStyle(
                              color: colorScheme.onSurface,
                            ),
                            validator: (value) => validateEmail(value),
                          ),

                          const SizedBox(height: 20),

                          // Password Field
                          Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            key: const Key('passwordField'),
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Create a password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            style: TextStyle(
                              color: colorScheme.onSurface,
                            ),
                            validator: (value) => validatePassword(value),
                          ),

                          const SizedBox(height: 20),

                          // Confirm Password Field
                          Text(
                            'Confirm Password',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            key: const Key('confirmPasswordField'),
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              hintText: 'Confirm your password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            style: TextStyle(
                              color: colorScheme.onSurface,
                            ),
                            validator: (value) =>
                                validateConfirmPassword(value, _passwordController.text),
                          ),

                          const SizedBox(height: 20),

                          // Terms Checkbox
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                value: _agreedToTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _agreedToTerms = value!;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  'I agree to the Terms of Service & Privacy Policy.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Create Account Button
                    CustomButton(
                      text: 'Create Account',
                      onPressed: () async {
                        // First validate the form fields and return early if validation fails
                        if (!_formKey.currentState!.validate()) {
                          return; // Exit early - validation errors will be displayed
                        }

                        // Only if form validation passes, proceed to check terms agreement
                        if (!_agreedToTerms) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You must agree to the terms.'),
                            ),
                          );
                          return;
                        }

                        final username = _usernameController.text.trim();
                        final email = _emailController.text.trim();
                        final password = _passwordController.text;

                        try {
                          final authService = context.read<AuthService>();

                          final isTaken = await authService.isDisplayNameTaken(username);

                          if (isTaken && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Username is already taken.'),
                              ),
                            );
                            return;
                          }

                          final User? firebaseUser =
                              await authService.createUserWithEmailAndPassword(
                            email,
                            password,
                            username,
                            _profileImageFile,
                          );

                          if (firebaseUser != null && context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => const LoginScreen(),
                                settings: const RouteSettings(
                                  arguments: {'showSuccessPopup': true},
                                ),
                              ),
                            );
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Account creation completed, but no user data returned.'),
                                ),
                              );
                            }
                          }
                        } catch (error) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to create account: ${error.toString()}'),
                              ),
                            );
                          }
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Divider
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(thickness: 1),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Or sign up with',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Divider(thickness: 1),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    const GoogleSignInButton(),

                    const SizedBox(height: 20),

                    // Already have account
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: TextStyle(color: colorScheme.onSurface),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Log In',
                              style: TextStyle(color: colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
