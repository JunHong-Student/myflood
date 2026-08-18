import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

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

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    // Temporary registration.
    // Later this will connect to Firebase Authentication/database.

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Registration successful. Please sign in.',
        ),
      ),
    );

    Navigator.pop(context);
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

              AppButton(
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