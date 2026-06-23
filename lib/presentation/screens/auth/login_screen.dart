import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/repositories/auth_provider.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(_emailCtrl.text, _passwordCtrl.text);

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      AppHelpers.showSnackBar(context, auth.errorMessage ?? 'Login failed',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.fitness_center,
                      color: Colors.white, size: 36),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to continue your journey',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined,
                            color: AppTheme.textSecondary),
                      ),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outlined,
                            color: AppTheme.textSecondary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppTheme.textSecondary,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen()),
                        ),
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.status == AuthStatus.loading
                              ? null
                              : _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppTheme.primary,
                          ),
                          child: auth.status == AuthStatus.loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Sign In',
                                  style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _DividerWithText(text: 'OR'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen()),
                    ),
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DividerWithText extends StatelessWidget {
  final String text;
  const _DividerWithText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppTheme.surfaceLight)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(text,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        ),
        const Expanded(child: Divider(color: AppTheme.surfaceLight)),
      ],
    );
  }
}
