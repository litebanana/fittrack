import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/repositories/auth_provider.dart';
import '../../../data/repositories/nutrition_measurement_provider.dart';
import '../../../data/models/nutrition.dart';
import '../../widgets/common/common_widgets.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nutrition = context.watch<NutritionProvider>();
    final auth = context.watch<AuthProvider>();
    final calorieGoal = auth.userProfile?.calorieGoal ?? 2500;
    final proteinGoal = auth.userProfile?.proteinGoal ?? 150;
    final carbGoal = auth.userProfile?.carbGoal ?? 300;
    final fatGoal = auth.userProfile?.fatGoal ?? 80;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: nutrition.selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx)
                      .copyWith(colorScheme: const ColorScheme.dark()),
                  child: child!,
                ),
              );
              if (picked != null && context.mounted) {
                final userId = context.read<AuthProvider>().userId!;
                context
                    .read<NutritionProvider>()
                    .setDate(userId, picked);
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFoodSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Food'),
        backgroundColor: AppTheme.primary,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _NutritionSummaryCard(
                    totalCalories: nutrition.totalCalories,
                    calorieGoal: calorieGoal,
                    totalProtein: nutrition.totalProtein,
                    proteinGoal: proteinGoal,
                    totalCarbs: nutrition.totalCarbs,
                    carbGoal: carbGoal,
                    totalFats: nutrition.totalFats,
                    fatGoal: fatGoal,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        AppFormatters.date(nutrition.selectedDate),
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          nutrition.todayEntries.isEmpty
              ? SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.restaurant_menu_outlined,
                    title: 'No Food Logged',
                    message:
                        'Track your meals to monitor your nutrition intake.',
                    actionLabel: 'Add Food',
                    onAction: () => _showAddFoodSheet(context),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final mealTypes = nutrition.entriesByMeal.keys.toList();
                        final mealType = mealTypes[i];
                        final entries =
                            nutrition.entriesByMeal[mealType] ?? [];
                        return _MealSection(
                          mealType: mealType,
                          entries: entries,
                        );
                      },
                      childCount: nutrition.entriesByMeal.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  void _showAddFoodSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _AddFoodSheet(),
    );
  }
}

class _NutritionSummaryCard extends StatelessWidget {
  final int totalCalories;
  final int calorieGoal;
  final double totalProtein;
  final int proteinGoal;
  final double totalCarbs;
  final int carbGoal;
  final double totalFats;
  final int fatGoal;

  const _NutritionSummaryCard({
    required this.totalCalories,
    required this.calorieGoal,
    required this.totalProtein,
    required this.proteinGoal,
    required this.totalCarbs,
    required this.carbGoal,
    required this.totalFats,
    required this.fatGoal,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (calorieGoal - totalCalories).clamp(0, calorieGoal);
    final progress = (totalCalories / calorieGoal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Consumed',
                      style: TextStyle(
                          color: AppTheme.textMuted, fontSize: 12)),
                  Text('$totalCalories',
                      style: const TextStyle(
                          color: AppTheme.accent,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                  const Text('kcal',
                      style: TextStyle(
                          color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 10,
                        backgroundColor: AppTheme.surfaceLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.accent),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$remaining',
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const Text('left',
                            style: TextStyle(
                                color: AppTheme.textMuted, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Goal',
                      style: TextStyle(
                          color: AppTheme.textMuted, fontSize: 12)),
                  Text('$calorieGoal',
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                  const Text('kcal',
                      style: TextStyle(
                          color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _MacroBar(
                      label: 'Protein',
                      current: totalProtein,
                      goal: proteinGoal.toDouble(),
                      color: AppTheme.primary)),
              const SizedBox(width: 12),
              Expanded(
                  child: _MacroBar(
                      label: 'Carbs',
                      current: totalCarbs,
                      goal: carbGoal.toDouble(),
                      color: AppTheme.secondary)),
              const SizedBox(width: 12),
              Expanded(
                  child: _MacroBar(
                      label: 'Fats',
                      current: totalFats,
                      goal: fatGoal.toDouble(),
                      color: AppTheme.warning)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final Color color;

  const _MacroBar({
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppTheme.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text('${current.toInt()}/${goal.toInt()}g',
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }
}

class _MealSection extends StatelessWidget {
  final String mealType;
  final List<FoodEntry> entries;

  const _MealSection({required this.mealType, required this.entries});

  @override
  Widget build(BuildContext context) {
    final totalCal = entries.fold(0, (sum, e) => sum + e.calories);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(mealType,
                  style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600)),
              Text('$totalCal kcal',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 12)),
            ],
          ),
        ),
        ...entries.map((e) => _FoodTile(entry: e)),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _FoodTile extends StatelessWidget {
  final FoodEntry entry;
  const _FoodTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.error),
      ),
      onDismissed: (_) {
        final userId = context.read<AuthProvider>().userId!;
        context.read<NutritionProvider>().deleteFoodEntry(userId, entry.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.surfaceLight),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.name,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600)),
                  Text(
                    'P: ${entry.protein.toInt()}g  C: ${entry.carbs.toInt()}g  F: ${entry.fats.toInt()}g',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '${entry.calories} kcal',
              style: const TextStyle(
                color: AppTheme.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddFoodSheet extends StatefulWidget {
  const _AddFoodSheet();

  @override
  State<_AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<_AddFoodSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  String _mealType = 'Breakfast';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _calCtrl.dispose();
    _proteinCtrl.dispose();
    _carbCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = context.read<AuthProvider>().userId!;
    final entry = FoodEntry(
      userId: userId,
      name: _nameCtrl.text,
      calories: int.parse(_calCtrl.text),
      protein: double.tryParse(_proteinCtrl.text) ?? 0,
      carbs: double.tryParse(_carbCtrl.text) ?? 0,
      fats: double.tryParse(_fatCtrl.text) ?? 0,
      mealType: _mealType,
    );
    await context.read<NutritionProvider>().addFoodEntry(entry);
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Log Food',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration:
                  const InputDecoration(labelText: 'Food Name *'),
              validator: (v) => Validators.required(v, 'Food name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _mealType,
              decoration: const InputDecoration(labelText: 'Meal'),
              items: FoodEntry.mealTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _mealType = v!),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _calCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Calories *'),
                    validator: (v) => Validators.positiveNumber(v, 'Calories'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _proteinCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Protein (g)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _carbCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Carbs (g)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _fatCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Fats (g)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Log Food'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
