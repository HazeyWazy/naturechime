import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naturechime/screens/create_account_screen.dart';
import 'package:naturechime/screens/main_screen.dart';
import 'package:naturechime/widgets/custom_button.dart';
import 'package:naturechime/widgets/google_sign_in_button.dart';
import 'package:naturechime/widgets/screen_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:naturechime/services/auth_service.dart';
import 'package:naturechime/utils/validators.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;

  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['showSuccessPopup'] == true) {
        Flushbar(
          title: 'Success',
          message: 'User account successfully created.',
          duration: const Duration(seconds: 5),
          flushbarPosition: FlushbarPosition.TOP,
          backgroundColor: Theme.of(context).colorScheme.primary,
          icon: Icon(
            Icons.check_circle_outline,
            size: 28.0,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          isDismissible: true,
          dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        ).show(context);
      }
    });
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authService = context.read<AuthService>();
        final user = await authService.signInWithEmailAndPassword(
          _email,
          _password,
        );
        if (user != null) {
          if (mounted) {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => const MainScreen(),
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _forgotPassword() async {
    final email = emailController.text.trim();

    if (validateEmail(email) != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid email for password reset.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      await authService.sendPasswordResetEmail(email);
      if (mounted) {
        Flushbar(
          title: 'Success',
          message: 'Password reset email sent.',
          duration: const Duration(seconds: 5),
          flushbarPosition: FlushbarPosition.TOP,
          backgroundColor: Theme.of(context).colorScheme.primary,
          icon: Icon(
            Icons.check_circle_outline,
            size: 28.0,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ).show(context);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (e is FirebaseAuthException) {
          errorMessage = 'Error (${e.code}): ${e.message}';
        }
        Flushbar(
          title: 'Error',
          message: errorMessage,
          duration: const Duration(seconds: 5),
          flushbarPosition: FlushbarPosition.TOP,
          backgroundColor: Theme.of(context).colorScheme.error,
          icon: Icon(
            Icons.error_outline,
            size: 28.0,
            color: Theme.of(context).colorScheme.onError,
          ),
        ).show(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
                    // Back button
                    IconButton(
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(
                        Icons.arrow_back,
                        color: colorScheme.onSurface,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),

                    const SizedBox(height: 20),

                    // Logo and Welcome Text
                    Center(
                      child: Column(
                        children: [
                          Image.asset('assets/images/naturechime_logo.png', height: 80),
                          const SizedBox(height: 12),
                          Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in to continue your sound journey',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email
                          Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: emailController,
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
                            validator: validateEmail,
                          ),

                          const SizedBox(height: 20),

                          // Password
                          Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                              ),
                            ),
                            style: TextStyle(
                              color: colorScheme.onSurface,
                            ),
                            validator: (value) =>
                                value != null && value.length >= 6 ? null : 'Password too short',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Your email or password is incorrect.',
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ),
                    if (_isLoading) const Center(child: CircularProgressIndicator()),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: _isLoading ? null : _forgotPassword,
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: colorScheme.primary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Log In Button
                    CustomButton(
                      text: 'Log In',
                      isPrimary: true,
                      onPressed: () {
                        if (_isLoading) return;
                        setState(() {
                          _email = emailController.text.trim();
                          _password = passwordController.text.trim();
                        });
                        _login();
                      },
                    ),

                    const SizedBox(height: 20),

                    // OR Divider
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: colorScheme.onSurface.withAlpha(180),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(thickness: 1),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const GoogleSignInButton(),

                    const SizedBox(height: 12),

                    // Sign up prompt
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(color: colorScheme.onSurface),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => const CreateAccountScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign up',
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
