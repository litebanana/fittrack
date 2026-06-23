import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/auth_provider.dart';
import '../../../data/repositories/workout_provider.dart';
import '../../../data/models/user_profile.dart';
import '../../widgets/common/common_widgets.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.userProfile;
    final workout = context.watch<WorkoutProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditSheet(context, profile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(profile),
            const SizedBox(height: 24),
            _buildStatsRow(workout),
            const SizedBox(height: 24),
            if (profile != null) _buildBMICard(profile),
            const SizedBox(height: 24),
            _buildInfoSection(profile),
            const SizedBox(height: 24),
            _buildGoalsSection(context, profile),
            const SizedBox(height: 24),
            _buildSignOutButton(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile? profile) {
    final name = profile?.name ?? 'Athlete';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary),
        ),
        Text(
          profile?.email ?? '',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            profile?.fitnessGoal ?? '',
            style: const TextStyle(color: AppTheme.primary, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(WorkoutProvider workout) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Workouts',
            value: '${workout.totalWorkouts}',
            icon: Icons.fitness_center,
            iconColor: AppTheme.primary,
            subtitle: 'completed',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'PRs',
            value: '${workout.personalRecords.length}',
            icon: Icons.emoji_events,
            iconColor: AppTheme.gold,
            subtitle: 'personal records',
          ),
        ),
      ],
    );
  }

  Widget _buildBMICard(UserProfile profile) {
    final bmi = AppHelpers.calculateBMI(profile.weight, profile.height);
    final category = AppHelpers.bmiCategory(bmi);
    final color = AppHelpers.bmiColor(bmi);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                bmi.toStringAsFixed(1),
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('BMI',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
              Text(category,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${profile.height.toStringAsFixed(0)} cm',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600)),
              Text('${profile.weight.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(UserProfile? profile) {
    if (profile == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Personal Info'),
        const SizedBox(height: 12),
        _InfoRow(label: 'Age', value: '${profile.age} years'),
        _InfoRow(label: 'Gender', value: profile.gender),
        _InfoRow(
            label: 'Activity Level', value: profile.activityLevel),
      ],
    );
  }

  Widget _buildGoalsSection(BuildContext context, UserProfile? profile) {
    if (profile == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Daily Goals'),
        const SizedBox(height: 12),
        _InfoRow(
            label: 'Calories',
            value: '${profile.calorieGoal} kcal'),
        _InfoRow(
            label: 'Protein', value: '${profile.proteinGoal}g'),
        _InfoRow(label: 'Carbs', value: '${profile.carbGoal}g'),
        _InfoRow(label: 'Fats', value: '${profile.fatGoal}g'),
      ],
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirm = await AppHelpers.showConfirmDialog(
            context,
            title: 'Sign Out',
            message: 'Are you sure you want to sign out?',
            confirmText: 'Sign Out',
            isDestructive: true,
          );
          if (confirm && context.mounted) {
            await context.read<AuthProvider>().signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );
          }
        },
        icon: const Icon(Icons.logout, color: AppTheme.error),
        label: const Text('Sign Out',
            style: TextStyle(color: AppTheme.error)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, UserProfile? profile) {
    if (profile == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EditProfileSheet(profile: profile),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ],
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  final UserProfile profile;
  const _EditProfileSheet({required this.profile});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _calCtrl;
  late TextEditingController _proteinCtrl;
  late String _fitnessGoal;
  late String _activityLevel;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _ageCtrl =
        TextEditingController(text: widget.profile.age.toString());
    _heightCtrl =
        TextEditingController(text: widget.profile.height.toString());
    _weightCtrl =
        TextEditingController(text: widget.profile.weight.toString());
    _calCtrl = TextEditingController(
        text: widget.profile.calorieGoal.toString());
    _proteinCtrl = TextEditingController(
        text: widget.profile.proteinGoal.toString());
    _fitnessGoal = widget.profile.fitnessGoal;
    _activityLevel = widget.profile.activityLevel;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _calCtrl.dispose();
    _proteinCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final updated = widget.profile.copyWith(
      name: _nameCtrl.text,
      age: int.tryParse(_ageCtrl.text) ?? widget.profile.age,
      height:
          double.tryParse(_heightCtrl.text) ?? widget.profile.height,
      weight:
          double.tryParse(_weightCtrl.text) ?? widget.profile.weight,
      calorieGoal:
          int.tryParse(_calCtrl.text) ?? widget.profile.calorieGoal,
      proteinGoal:
          int.tryParse(_proteinCtrl.text) ?? widget.profile.proteinGoal,
      fitnessGoal: _fitnessGoal,
      activityLevel: _activityLevel,
    );
    await context.read<AuthProvider>().updateProfile(updated);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Profile',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Full Name'),
                validator: (v) => Validators.required(v, 'Name'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Age'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _weightCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Weight (kg)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _heightCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration:
                    const InputDecoration(labelText: 'Height (cm)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _fitnessGoal,
                decoration:
                    const InputDecoration(labelText: 'Fitness Goal'),
                items: AppConstants.fitnessGoals
                    .map((g) =>
                        DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _fitnessGoal = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _activityLevel,
                decoration: const InputDecoration(
                    labelText: 'Activity Level'),
                items: [
                  'Sedentary',
                  'Lightly Active',
                  'Moderately Active',
                  'Very Active',
                ]
                    .map((a) =>
                        DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _activityLevel = v!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _calCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Calorie Goal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _proteinCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Protein Goal (g)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
