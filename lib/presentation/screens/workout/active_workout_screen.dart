import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/repositories/workout_provider.dart';
import '../../../data/models/workout.dart';
import '../../widgets/common/common_widgets.dart';
import 'add_exercise_screen.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late Timer _timer;
  int _seconds = 0;
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final workout = context.read<WorkoutProvider>().activeWorkout;
    _nameCtrl.text = workout?.name ?? '';
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _nameCtrl.dispose();
    super.dispose();
  }

  String get _elapsed {
    final h = _seconds ~/ 3600;
    final m = (_seconds % 3600) ~/ 60;
    final s = _seconds % 60;
    if (h > 0) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<bool> _confirmDiscard() async {
    return await AppHelpers.showConfirmDialog(
      context,
      title: 'Discard Workout',
      message: 'Are you sure you want to discard this workout?',
      confirmText: 'Discard',
      isDestructive: true,
    );
  }

  Future<void> _saveWorkout() async {
    final provider = context.read<WorkoutProvider>();
    provider.updateWorkoutName(_nameCtrl.text.isEmpty ? 'Workout' : _nameCtrl.text);

    final success = await provider.saveWorkout();
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      AppHelpers.showSnackBar(context, 'Workout saved! 💪');
    } else {
      AppHelpers.showSnackBar(context, provider.error ?? 'Failed to save',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final discard = await _confirmDiscard();
        if (discard) context.read<WorkoutProvider>().cancelWorkout();
        return discard;
      },
      child: Scaffold(
        appBar: AppBar(
          title: SizedBox(
            width: 180,
            child: TextField(
              controller: _nameCtrl,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Workout Name',
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final discard = await _confirmDiscard();
              if (discard && mounted) {
                context.read<WorkoutProvider>().cancelWorkout();
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _elapsed,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: Consumer<WorkoutProvider>(
          builder: (ctx, provider, _) {
            final workout = provider.activeWorkout;
            if (workout == null) return const LoadingWidget();

            return Column(
              children: [
                Expanded(
                  child: workout.exercises.isEmpty
                      ? EmptyState(
                          icon: Icons.add_circle_outline,
                          title: 'Add Your First Exercise',
                          message:
                              'Tap the button below to add exercises to your workout.',
                          actionLabel: 'Add Exercise',
                          onAction: _addExercise,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          itemCount: workout.exercises.length,
                          itemBuilder: (ctx, i) => _ExerciseBlock(
                            exercise: workout.exercises[i],
                            exerciseIndex: i,
                          ),
                        ),
                ),
                _buildBottomBar(context, provider),
              ],
            );
          },
        ),
      ),
    );
  }

  void _addExercise() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddExerciseScreen()),
    );
  }

  Widget _buildBottomBar(BuildContext context, WorkoutProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.surfaceLight)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _addExercise,
              icon: const Icon(Icons.add),
              label: const Text('Add Exercise'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: provider.isLoading ? null : _saveWorkout,
              icon: provider.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check),
              label: const Text('Finish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseBlock extends StatelessWidget {
  final WorkoutExercise exercise;
  final int exerciseIndex;

  const _ExerciseBlock({required this.exercise, required this.exerciseIndex});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WorkoutProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        exercise.muscleGroup,
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppTheme.error, size: 20),
                  onPressed: () => provider.removeExercise(exercise.id),
                ),
              ],
            ),
          ),
          // Sets Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                    width: 30,
                    child: Text('Set',
                        style: TextStyle(
                            color: AppTheme.textMuted, fontSize: 12))),
                SizedBox(width: 12),
                Expanded(
                    child: Text('Weight (kg)',
                        style: TextStyle(
                            color: AppTheme.textMuted, fontSize: 12))),
                SizedBox(width: 12),
                Expanded(
                    child: Text('Reps',
                        style: TextStyle(
                            color: AppTheme.textMuted, fontSize: 12))),
                SizedBox(
                    width: 40,
                    child: Text('✓',
                        style: TextStyle(
                            color: AppTheme.textMuted, fontSize: 12),
                        textAlign: TextAlign.center)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          ...exercise.sets.asMap().entries.map(
                (entry) => _SetRow(
                  exercise: exercise,
                  set: entry.value,
                  setNumber: entry.key + 1,
                ),
              ),
          // Add Set
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  final lastSet = exercise.sets.isNotEmpty
                      ? exercise.sets.last
                      : null;
                  provider.addSet(
                    exercise.id,
                    ExerciseSet(
                      weight: lastSet?.weight ?? 0,
                      reps: lastSet?.reps ?? 10,
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Set', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  side: const BorderSide(color: AppTheme.surfaceLight),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetRow extends StatefulWidget {
  final WorkoutExercise exercise;
  final ExerciseSet set;
  final int setNumber;

  const _SetRow({
    required this.exercise,
    required this.set,
    required this.setNumber,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late TextEditingController _weightCtrl;
  late TextEditingController _repsCtrl;

  @override
  void initState() {
    super.initState();
    _weightCtrl = TextEditingController(
        text: widget.set.weight > 0 ? widget.set.weight.toString() : '');
    _repsCtrl = TextEditingController(
        text: widget.set.reps > 0 ? widget.set.reps.toString() : '');
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  void _updateSet() {
    final provider = context.read<WorkoutProvider>();
    final weight = double.tryParse(_weightCtrl.text) ?? 0;
    final reps = int.tryParse(_repsCtrl.text) ?? 0;
    provider.updateSet(
      widget.exercise.id,
      widget.set.id,
      widget.set.copyWith(weight: weight, reps: reps),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WorkoutProvider>();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: widget.set.isCompleted
          ? AppTheme.success.withOpacity(0.05)
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '${widget.setNumber}',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _weightCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style:
                  const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              onChanged: (_) => _updateSet(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _repsCtrl,
              keyboardType: TextInputType.number,
              style:
                  const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              onChanged: (_) => _updateSet(),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: GestureDetector(
              onTap: () {
                provider.toggleSetCompleted(
                    widget.exercise.id, widget.set.id);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: widget.set.isCompleted
                      ? AppTheme.success
                      : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.check,
                  color: widget.set.isCompleted
                      ? Colors.white
                      : AppTheme.textMuted,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
