import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/auth_provider.dart';
import 'login_screen.dart';
import '../main_navigation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  String _gender = 'Male';
  String _fitnessGoal = AppConstants.fitnessGoals.first;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  int _currentStep = 0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
      name: _nameCtrl.text,
      age: int.parse(_ageCtrl.text),
      height: double.parse(_heightCtrl.text),
      weight: double.parse(_weightCtrl.text),
      fitnessGoal: _fitnessGoal,
      gender: _gender,
    );

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      AppHelpers.showSnackBar(
          context, auth.errorMessage ?? 'Registration failed',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              _register();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep--);
          },
          connectorColor: WidgetStateProperty.all(AppTheme.primary),
          steps: [
            Step(
              title: const Text('Account Info'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline,
                          color: AppTheme.textSecondary),
                    ),
                    validator: (v) => Validators.required(v, 'Name'),
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordCtrl,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outlined,
                          color: AppTheme.textSecondary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppTheme.textSecondary,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) {
                      if (v != _passwordCtrl.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Physical Info'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ageCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Age',
                            suffixText: 'years',
                          ),
                          validator: (v) => Validators.positiveNumber(v, 'Age'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _gender,
                          decoration: const InputDecoration(labelText: 'Gender'),
                          items: ['Male', 'Female', 'Other']
                              .map((g) =>
                                  DropdownMenuItem(value: g, child: Text(g)))
                              .toList(),
                          onChanged: (v) => setState(() => _gender = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _heightCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Height',
                            suffixText: 'cm',
                          ),
                          validator: (v) =>
                              Validators.positiveNumber(v, 'Height'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _weightCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Weight',
                            suffixText: 'kg',
                          ),
                          validator: (v) =>
                              Validators.positiveNumber(v, 'Weight'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Your Goal'),
              isActive: _currentStep >= 2,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('What is your main fitness goal?',
                      style: TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 16),
                  ...AppConstants.fitnessGoals.map(
                    (goal) => _GoalOption(
                      label: goal,
                      isSelected: _fitnessGoal == goal,
                      onTap: () => setState(() => _fitnessGoal = goal),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<AuthProvider>(
                    builder: (ctx, auth, _) => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            auth.status == AuthStatus.loading ? null : _register,
                        child: auth.status == AuthStatus.loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Create Account'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.15)
              : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.primary : AppTheme.textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
