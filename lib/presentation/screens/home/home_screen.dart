import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/repositories/auth_provider.dart';
import '../../../data/repositories/workout_provider.dart';
import '../../../data/repositories/nutrition_measurement_provider.dart';
import '../../widgets/common/common_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {},
          color: AppTheme.primary,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(child: _buildStatsRow(context)),
              SliverToBoxAdapter(child: _buildNutritionCard(context)),
              SliverToBoxAdapter(child: _buildPRCard(context)),
              SliverToBoxAdapter(child: _buildRecentWorkouts(context)),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.userProfile?.name.split(' ').first ?? 'Athlete';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final workout = context.watch<WorkoutProvider>();
    final measurement = context.watch<MeasurementProvider>();

    final weight = measurement.latestMeasurement?.weight ??
        context.watch<AuthProvider>().userProfile?.weight ??
        0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              title: 'Current Weight',
              value: '${weight.toStringAsFixed(1)} kg',
              icon: Icons.monitor_weight_outlined,
              iconColor: AppTheme.secondary,
              subtitle: _weightChangeSub(measurement),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Workouts',
              value: '${workout.totalWorkouts}',
              icon: Icons.fitness_center,
              iconColor: AppTheme.primary,
              subtitle: 'total completed',
            ),
          ),
        ],
      ),
    );
  }

  String? _weightChangeSub(MeasurementProvider m) {
    final change = m.weightChange;
    if (change == null) return null;
    if (change > 0) return '+${change.toStringAsFixed(1)} kg overall';
    return '${change.toStringAsFixed(1)} kg overall';
  }

  Widget _buildNutritionCard(BuildContext context) {
    final nutrition = context.watch<NutritionProvider>();
    final auth = context.watch<AuthProvider>();
    final calorieGoal = auth.userProfile?.calorieGoal ?? 2500;
    final proteinGoal = auth.userProfile?.proteinGoal ?? 150;
    final progress = nutrition.totalCalories / calorieGoal;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GradientCard(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A35), Color(0xFF252545)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Nutrition",
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  AppFormatters.shortDate(DateTime.now()),
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircularProgressWidget(
                  progress: progress,
                  label: 'Calories',
                  value: '${nutrition.totalCalories}',
                  total: '$calorieGoal',
                  color: AppTheme.accent,
                ),
                CircularProgressWidget(
                  progress: nutrition.totalProtein / proteinGoal,
                  label: 'Protein',
                  value: '${nutrition.totalProtein.toInt()}g',
                  total: '${proteinGoal}g',
                  color: AppTheme.primary,
                ),
                CircularProgressWidget(
                  progress: nutrition.totalCarbs /
                      (auth.userProfile?.carbGoal ?? 300),
                  label: 'Carbs',
                  value: '${nutrition.totalCarbs.toInt()}g',
                  total: '${auth.userProfile?.carbGoal ?? 300}g',
                  color: AppTheme.secondary,
                ),
                CircularProgressWidget(
                  progress: nutrition.totalFats /
                      (auth.userProfile?.fatGoal ?? 80),
                  label: 'Fats',
                  value: '${nutrition.totalFats.toInt()}g',
                  total: '${auth.userProfile?.fatGoal ?? 80}g',
                  color: AppTheme.warning,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: AppTheme.surfaceLight,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.accent),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              progress >= 1
                  ? 'Calorie goal reached! 🎉'
                  : '${(calorieGoal - nutrition.totalCalories).clamp(0, calorieGoal)} kcal remaining',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPRCard(BuildContext context) {
    final workout = context.watch<WorkoutProvider>();
    final pr = workout.latestPR;

    if (pr == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GradientCard(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1A45), Color(0xFF1A2A45)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.gold.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events,
                  color: AppTheme.gold, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Latest Personal Record 🏆',
                    style: TextStyle(
                        color: AppTheme.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pr.exerciseName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${pr.weight.toStringAsFixed(1)}kg × ${pr.reps} reps'
                    '${pr.improvement > 0 ? '  +${pr.improvement.toStringAsFixed(1)}kg' : ''}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentWorkouts(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final recent = workoutProvider.getRecentWorkouts(count: 3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Recent Workouts'),
          const SizedBox(height: 12),
          if (recent.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.surfaceLight),
              ),
              child: const Center(
                child: Text(
                  'No workouts yet. Start your first workout!',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                ),
              ),
            )
          else
            ...recent.map((workout) => _WorkoutTile(workout: workout)),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}

class _WorkoutTile extends StatelessWidget {
  final dynamic workout;
  const _WorkoutTile({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fitness_center,
                color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${workout.exercises.length} exercises • ${AppFormatters.date(workout.date)}',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${workout.totalSets} sets',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppTheme.textMuted, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
