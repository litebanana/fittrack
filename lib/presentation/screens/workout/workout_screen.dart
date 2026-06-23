import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/repositories/auth_provider.dart';
import '../../../data/repositories/workout_provider.dart';
import '../../../data/models/workout.dart';
import '../../widgets/common/common_widgets.dart';
import 'active_workout_screen.dart';
import 'workout_detail_screen.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startNewWorkout(context),
        icon: const Icon(Icons.add),
        label: const Text('New Workout'),
        backgroundColor: AppTheme.primary,
      ),
      body: workoutProvider.workouts.isEmpty
          ? EmptyState(
              icon: Icons.fitness_center,
              title: 'No Workouts Yet',
              message:
                  'Start tracking your workouts to see your progress over time.',
              actionLabel: 'Start Workout',
              onAction: () => _startNewWorkout(context),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: workoutProvider.workouts.length,
              itemBuilder: (ctx, i) {
                final workout = workoutProvider.workouts[i];
                return _WorkoutCard(workout: workout);
              },
            ),
    );
  }

  void _startNewWorkout(BuildContext context) {
    final userId = context.read<AuthProvider>().userId!;
    context.read<WorkoutProvider>().startNewWorkout(userId);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final Workout workout;
  const _WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => WorkoutDetailScreen(workout: workout)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.surfaceLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    workout.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _MuscleGroupChips(groups: workout.muscleGroups),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppFormatters.date(workout.date),
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppTheme.surfaceLight),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatBadge(
                  icon: Icons.format_list_numbered,
                  value: '${workout.exercises.length}',
                  label: 'exercises',
                ),
                const SizedBox(width: 16),
                _StatBadge(
                  icon: Icons.repeat,
                  value: '${workout.totalSets}',
                  label: 'sets',
                ),
                const SizedBox(width: 16),
                _StatBadge(
                  icon: Icons.fitness_center,
                  value: '${(workout.totalVolume / 1000).toStringAsFixed(1)}t',
                  label: 'volume',
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textMuted,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MuscleGroupChips extends StatelessWidget {
  final List<String> groups;
  const _MuscleGroupChips({required this.groups});

  @override
  Widget build(BuildContext context) {
    final displayGroups = groups.take(2).toList();
    return Row(
      children: displayGroups
          .map((g) => Container(
                margin: const EdgeInsets.only(left: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  g,
                  style: const TextStyle(
                      color: AppTheme.primary, fontSize: 11),
                ),
              ))
          .toList(),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatBadge(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
