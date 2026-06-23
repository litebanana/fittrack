import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/repositories/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.sendPasswordReset(_emailCtrl.text);
    if (!mounted) return;
    if (success) {
      setState(() => _emailSent = true);
    } else {
      AppHelpers.showSnackBar(
          context, auth.errorMessage ?? 'Failed to send reset email',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _emailSent ? _buildSuccessView() : _buildFormView(),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Forgot your password?',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 12),
        const Text(
          "Enter your email and we'll send you a reset link.",
          style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 32),
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined,
                  color: AppTheme.textSecondary),
            ),
            validator: Validators.email,
          ),
        ),
        const SizedBox(height: 24),
        Consumer<AuthProvider>(
          builder: (ctx, auth, _) => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  auth.status == AuthStatus.loading ? null : _send,
              child: auth.status == AuthStatus.loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Send Reset Link'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              color: AppTheme.success,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Check your email!',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            'We sent a password reset link to\n${_emailCtrl.text}',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 15, color: AppTheme.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }
}
