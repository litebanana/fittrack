import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/repositories/auth_provider.dart';
import '../../../data/repositories/workout_provider.dart';
import '../../../data/models/workout.dart';
import '../../widgets/common/common_widgets.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.error),
            onPressed: () => _deleteWorkout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 20),
          const Text('Exercises',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          ...workout.exercises.map((e) => _ExerciseDetailCard(exercise: e)),
          if (workout.notes.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.surfaceLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Notes',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(workout.notes,
                      style: const TextStyle(color: AppTheme.textPrimary)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(AppFormatters.date(workout.date),
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SumStat(
                  label: 'Exercises',
                  value: '${workout.exercises.length}'),
              _SumStat(label: 'Sets', value: '${workout.totalSets}'),
              _SumStat(
                  label: 'Volume',
                  value:
                      '${(workout.totalVolume / 1000).toStringAsFixed(1)}t'),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _deleteWorkout(BuildContext context) async {
    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Delete Workout',
      message: 'This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (!confirm || !context.mounted) return;
    final userId = context.read<AuthProvider>().userId!;
    await context.read<WorkoutProvider>().deleteWorkout(userId, workout.id);
    if (context.mounted) Navigator.pop(context);
  }
}

class _SumStat extends StatelessWidget {
  final String label;
  final String value;
  const _SumStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _ExerciseDetailCard extends StatelessWidget {
  final WorkoutExercise exercise;
  const _ExerciseDetailCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(exercise.name,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          Text(exercise.muscleGroup,
              style:
                  const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 12),
          ...exercise.sets.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text('${e.key + 1}',
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(e.value.display,
                        style: const TextStyle(color: AppTheme.textPrimary)),
                    if (e.value.isCompleted) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle,
                          color: AppTheme.success, size: 14),
                    ],
                  ],
                ),
              )),
          const SizedBox(height: 8),
          Text(
              'Max: ${exercise.maxWeight.toStringAsFixed(1)}kg  •  Volume: ${exercise.totalVolume.toStringAsFixed(0)}kg',
              style:
                  const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}
