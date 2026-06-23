import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/workout_provider.dart';
import '../../../data/models/workout.dart';
import '../../widgets/common/common_widgets.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  String _selectedMuscleGroup = AppConstants.muscleGroups.first;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<String> get _filteredExercises {
    final exercises =
        ExerciseDatabase.exercises[_selectedMuscleGroup] ?? [];
    if (_searchQuery.isEmpty) return exercises;
    return exercises
        .where((e) =>
            e.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _addExercise(String name) {
    final exercise = WorkoutExercise(
      name: name,
      muscleGroup: _selectedMuscleGroup,
      sets: [ExerciseSet(weight: 0, reps: 10)],
    );
    context.read<WorkoutProvider>().addExercise(exercise);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exercise'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon:
                    const Icon(Icons.search, color: AppTheme.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: AppTheme.textSecondary),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: AppConstants.muscleGroups.length,
              itemBuilder: (ctx, i) {
                final group = AppConstants.muscleGroups[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FitChip(
                    label: group,
                    isSelected: _selectedMuscleGroup == group,
                    onTap: () =>
                        setState(() => _selectedMuscleGroup = group),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filteredExercises.isEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    title: 'No exercises found',
                    message: 'Try a different search term',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredExercises.length + 1,
                    itemBuilder: (ctx, i) {
                      if (i == _filteredExercises.length) {
                        return _buildCustomExerciseButton();
                      }
                      final name = _filteredExercises[i];
                      return _ExerciseTile(
                        name: name,
                        muscleGroup: _selectedMuscleGroup,
                        onAdd: () => _addExercise(name),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomExerciseButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: OutlinedButton.icon(
        onPressed: () => _showCustomExerciseDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Custom Exercise'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  void _showCustomExerciseDialog() {
    final nameCtrl = TextEditingController();
    String muscleGroup = _selectedMuscleGroup;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Custom Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Exercise Name',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: muscleGroup,
              decoration: const InputDecoration(labelText: 'Muscle Group'),
              items: AppConstants.muscleGroups
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => muscleGroup = v!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                Navigator.pop(ctx);
                final exercise = WorkoutExercise(
                  name: nameCtrl.text,
                  muscleGroup: muscleGroup,
                  sets: [ExerciseSet(weight: 0, reps: 10)],
                );
                context.read<WorkoutProvider>().addExercise(exercise);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final String name;
  final String muscleGroup;
  final VoidCallback onAdd;

  const _ExerciseTile({
    required this.name,
    required this.muscleGroup,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.fitness_center,
              color: AppTheme.primary, size: 20),
        ),
        title: Text(
          name,
          style: const TextStyle(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          muscleGroup,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
        ),
        trailing: GestureDetector(
          onTap: onAdd,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}
