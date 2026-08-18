import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() {
    // Temporary login for UI testing.
    // Later this will connect to Firebase Authentication.

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainScreen(),
      ),
    );
  }

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
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

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Later: Forgot password screen
                      },
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ==========================================
                  // SIGN IN
                  // ==========================================

                  AppButton(
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