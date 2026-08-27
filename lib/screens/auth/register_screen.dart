import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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

  Future<void> _register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty) {
      _showError('Please enter your full name.');
      return;
    }

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
      _showError('Please enter a password.');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await userCredential.user?.updateDisplayName(name);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful. Please sign in.'),
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showError('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        _showError('The account already exists for that email.');
      } else {
        _showError(e.message ?? 'An error occurred during registration.');
      }
    } catch (e) {
      _showError('Failed to register. Please try again.');
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
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('Register'),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Account',
                style: AppTextStyles.title,
              ),

              const SizedBox(height: 6),

              const Text(
                'Register for the MyFlood Malaysia monitoring portal',
                style: AppTextStyles.bodySecondary,
              ),

              const SizedBox(height: 28),

              const Text(
                'FULL NAME',
                style: AppTextStyles.caption,
              ),

              const SizedBox(height: 8),

              AppTextField(
                hintText: 'Enter your full name',
                controller: nameController,
                prefixIcon: Icons.person_outline,
              ),

              const SizedBox(height: 18),

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

              const Text(
                'PASSWORD',
                style: AppTextStyles.caption,
              ),

              const SizedBox(height: 8),

              AppTextField(
                hintText: 'Create a password',
                controller: passwordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
              ),

              const SizedBox(height: 18),

              const Text(
                'CONFIRM PASSWORD',
                style: AppTextStyles.caption,
              ),

              const SizedBox(height: 8),

              AppTextField(
                hintText: 'Confirm your password',
                controller: confirmPasswordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
              ),

              const SizedBox(height: 28),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AppButton(
                      text: 'CREATE ACCOUNT',
                      onPressed: _register,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}