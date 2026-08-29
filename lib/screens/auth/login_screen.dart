import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../home/main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? true;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.critical,
      ),
    );
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      _showError('Please enter your email address.');
      return;
    }
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      _showError('Please enter a valid email address.');
      return;
    }

    if (password.isEmpty) {
      _showError('Please enter your password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'wrong-password') {
        _showError('Invalid email or password.');
      } else {
        _showError(e.message ?? 'An error occurred during sign in.');
      }
    } catch (e) {
      _showError('Failed to sign in. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );
  }

  Future<void> _resetPassword(String email, BuildContext dialogContext) async {
    final emailText = email.trim();
    if (emailText.isEmpty) {
      _showError('Please enter your email address.');
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(emailText)) {
      _showError('Please enter a valid email address.');
      return;
    }

    Navigator.pop(dialogContext); // Close dialog before starting the network call.

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailText);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('If an account exists for this email, a password reset link has been sent. Please check your inbox.'),
            backgroundColor: AppColors.normal,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showError('No user found for that email address.');
      } else {
        _showError(e.message ?? 'Failed to send password reset email.');
      }
    } catch (e) {
      _showError('An error occurred. Please try again.');
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: emailController.text);
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your email address to receive a password reset link.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 16),
              AppTextField(
                hintText: 'Email address',
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => _resetPassword(resetEmailController.text, dialogContext),
              child: const Text('Send Email'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==========================================
                  // LOGO / APP NAME
                  // ==========================================

                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          child: const Icon(
                            Icons.water_drop_outlined,
                            color: AppColors.primaryBlue,
                            size: 30,
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'MyFlood Malaysia',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'National Flood Information System',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ==========================================
                  // LOGIN TITLE
                  // ==========================================

                  const Text(
                    'Sign In',
                    style: AppTextStyles.title,
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Access the MyFlood Malaysia monitoring portal',
                    style: AppTextStyles.bodySecondary,
                  ),

                  const SizedBox(height: 28),

                  // ==========================================
                  // EMAIL
                  // ==========================================

                  const Text(
                    'EMAIL ADDRESS',
                    style: AppTextStyles.caption,
                  ),

                  const SizedBox(height: 8),

                  AppTextField(
                    hintText: 'officer@water.gov.my',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 18),

                  // ==========================================
                  // PASSWORD
                  // ==========================================

                  const Text(
                    'PASSWORD',
                    style: AppTextStyles.caption,
                  ),

                  const SizedBox(height: 8),

                  AppTextField(
                    hintText: 'Enter your password',
                    controller: passwordController,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (bool? value) {
                              setState(() {
                                _rememberMe = value ?? true;
                              });
                              SharedPreferences.getInstance().then((prefs) {
                                prefs.setBool('remember_me', _rememberMe);
                              });
                            },
                            activeColor: AppColors.primaryBlue,
                            side: const BorderSide(color: AppColors.textSecondary),
                          ),
                          const Text(
                            'Remember Me',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ==========================================
                  // SIGN IN
                  // ==========================================

                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : AppButton(
                          text: 'SIGN IN',
                          onPressed: _login,
                        ),

                  const SizedBox(height: 24),

                  // ==========================================
                  // REGISTER
                  // ==========================================

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: AppTextStyles.bodySecondary,
                        ),

                        GestureDetector(
                          onTap: _openRegister,
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Center(
                    child: Text(
                      '● All systems operational',
                      style: TextStyle(
                        color: AppColors.normal,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}