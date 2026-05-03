import 'package:flutter/material.dart';
import '../main.dart';

// ============================================================================
// AUTH SCREEN - Rate Mate
// ============================================================================
// Login/Register functionality with Blue-Cyan gradient background
// and Pacifico font for logo text
// ============================================================================

class AuthScreen extends StatefulWidget {
  final AppData appData;
  const AuthScreen({required this.appData, super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  String error = '';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void toggleMode() {
    setState(() {
      isLogin = !isLogin;
      error = '';
    });
  }

  Future<void> submit() async {
    final email = emailController.text;
    final password = passwordController.text;
    if (email.isEmpty ||
        password.isEmpty ||
        (!isLogin && nameController.text.trim().isEmpty)) {
      setState(() => error = 'Please fill all required fields');
      return;
    }

    final bool success;
    if (isLogin) {
      success = widget.appData.login(email, password);
    } else {
      success = await widget.appData.register(
        nameController.text,
        email,
        password,
      );
    }

    if (!success) {
      if (!mounted) return;
      setState(
        () => error =
            isLogin
                ? 'Login failed: check credentials'
                : 'Registration failed: email already used',
      );
      return;
    }
    if (mounted) setState(() => error = '');
  }

  @override
  Widget build(BuildContext context) {
    // Blue-Cyan gradient background as requested
    return Scaffold(
      backgroundColor: AppDesignTokens.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF3B82F6), // Blue-Cyan token start
              Color(0xFF06B6D4), // Blue-Cyan token end
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Logo/Title with Pacifico font
                const Center(
                  child: Text(
                    'RateMate',
                    style: TextStyle(
                      fontFamily: AppDesignTokens.handwritingFont,
                      fontSize: 42,
                      color: AppDesignTokens.primaryForeground,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    isLogin ? 'Welcome back!' : 'Create your account',
                    style: TextStyle(
                      fontFamily: AppDesignTokens.fontFamily,
                      fontSize: 16,
                      color: AppDesignTokens.primaryForeground.withOpacity(0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                if (!isLogin)
                  Container(
                    decoration: BoxDecoration(
                      color: AppDesignTokens.card,
                      // 16px border radius
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppDesignTokens.foreground.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: nameController,
                      style: const TextStyle(
                        fontFamily: AppDesignTokens.fontFamily,
                        color: AppDesignTokens.foreground,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: const TextStyle(
                          fontFamily: AppDesignTokens.fontFamily,
                          color: AppDesignTokens.mutedForeground,
                        ),
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: AppDesignTokens.mutedForeground,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppDesignTokens.ring,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppDesignTokens.inputBackground,
                      ),
                    ),
                  ),
                if (!isLogin) const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppDesignTokens.card,
                    // 16px border radius
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppDesignTokens.foreground.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: emailController,
                    style: const TextStyle(
                      fontFamily: AppDesignTokens.fontFamily,
                      color: AppDesignTokens.foreground,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(
                        fontFamily: AppDesignTokens.fontFamily,
                        color: AppDesignTokens.mutedForeground,
                      ),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppDesignTokens.mutedForeground,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppDesignTokens.ring,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: AppDesignTokens.inputBackground,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppDesignTokens.card,
                    // 16px border radius
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppDesignTokens.foreground.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: passwordController,
                    style: const TextStyle(
                      fontFamily: AppDesignTokens.fontFamily,
                      color: AppDesignTokens.foreground,
                    ),
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(
                        fontFamily: AppDesignTokens.fontFamily,
                        color: AppDesignTokens.mutedForeground,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppDesignTokens.mutedForeground,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppDesignTokens.ring,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: AppDesignTokens.inputBackground,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Using elevatedButtonTheme style from main.dart
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: submit,
                    child: Text(
                      isLogin ? 'Sign In' : 'Create Account',
                      style: const TextStyle(
                        fontFamily: AppDesignTokens.fontFamily,
                        fontWeight: AppDesignTokens.fontWeightMedium,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: toggleMode,
                    child: Text(
                      isLogin
                          ? "Don't have an account? Sign up"
                          : 'Already have an account? Login',
                      style: TextStyle(
                        fontFamily: AppDesignTokens.fontFamily,
                        color: AppDesignTokens.primaryForeground.withOpacity(0.9),
                      ),
                    ),
                  ),
                ),
                if (error.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppDesignTokens.destructive.withOpacity(0.1),
                      // 16px border radius
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppDesignTokens.destructive.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppDesignTokens.destructive,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            error,
                            style: const TextStyle(
                              fontFamily: AppDesignTokens.fontFamily,
                              color: AppDesignTokens.destructive,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}