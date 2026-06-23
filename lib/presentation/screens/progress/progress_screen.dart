import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/repositories/auth_provider.dart';
import '../../../data/repositories/measurement_provider_alias.dart';
import '../../../data/models/measurement.dart';
import '../../widgets/common/common_widgets.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'Measurements'),
            Tab(text: 'Charts'),
            Tab(text: 'Photos'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMeasurementSheet(context),
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _MeasurementsTab(),
          _ChartsTab(),
          _PhotosTab(),
        ],
      ),
    );
  }

  void _showAddMeasurementSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _AddMeasurementSheet(),
    );
  }
}

class _MeasurementsTab extends StatelessWidget {
  const _MeasurementsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MeasurementProvider>();
    final measurements = provider.measurements;

    if (measurements.isEmpty) {
      return EmptyState(
        icon: Icons.monitor_weight_outlined,
        title: 'No Measurements',
        message: 'Start tracking your body measurements to see progress.',
        actionLabel: 'Add Measurement',
        onAction: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppTheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => const _AddMeasurementSheet(),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: measurements.length,
      itemBuilder: (ctx, i) => _MeasurementCard(m: measurements[i]),
    );
  }
}

class _MeasurementCard extends StatelessWidget {
  final BodyMeasurement m;
  const _MeasurementCard({required this.m});

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
          Row(
            children: [
              Text(AppFormatters.date(m.date),
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
              const Spacer(),
              Text('${m.weight.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          if (m.bodyFat != null || m.chest != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppTheme.surfaceLight),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (m.bodyFat != null)
                  _Stat('Body Fat', '${m.bodyFat!.toStringAsFixed(1)}%'),
                if (m.chest != null)
                  _Stat('Chest', '${m.chest!.toStringAsFixed(1)}cm'),
                if (m.waist != null)
                  _Stat('Waist', '${m.waist!.toStringAsFixed(1)}cm'),
                if (m.arms != null)
                  _Stat('Arms', '${m.arms!.toStringAsFixed(1)}cm'),
                if (m.legs != null)
                  _Stat('Legs', '${m.legs!.toStringAsFixed(1)}cm'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        Text(value,
            style: const TextStyle(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ChartsTab extends StatelessWidget {
  const _ChartsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MeasurementProvider>();
    final history = provider.getWeightHistory(days: 60);

    if (history.length < 2) {
      return const EmptyState(
        icon: Icons.show_chart,
        title: 'Not Enough Data',
        message:
            'Add at least 2 measurements to see your progress chart.',
      );
    }

    final spots = history.reversed.toList().asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight);
    }).toList();

    final minY =
        spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 2;
    final maxY =
        spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weight Progress',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text('Last ${history.length} entries',
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppTheme.surfaceLight,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}',
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 11),
                      ),
                    ),
                  ),
                  bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: AppTheme.primary,
                        strokeWidth: 2,
                        strokeColor: AppTheme.background,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withOpacity(0.2),
                          AppTheme.primary.withOpacity(0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotosTab extends StatelessWidget {
  const _PhotosTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MeasurementProvider>();
    final photos = provider.progressPhotos;
    final userId = context.read<AuthProvider>().userId!;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: photos.length + 3,
      itemBuilder: (ctx, i) {
        if (i < 3) {
          final types = ['front', 'side', 'back'];
          final type = types[i];
          final existing = photos.where((p) => p.type == type).toList();
          if (existing.isNotEmpty) {
            return _PhotoTile(photo: existing.first, userId: userId);
          }
          return _AddPhotoTile(
            type: type,
            userId: userId,
            provider: provider,
          );
        }
        final photo = photos[i - 3];
        return _PhotoTile(photo: photo, userId: userId);
      },
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final ProgressPhoto photo;
  final String userId;
  const _PhotoTile({required this.photo, required this.userId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        final confirm = await AppHelpers.showConfirmDialog(
          context,
          title: 'Delete Photo',
          message: 'Delete this progress photo?',
          confirmText: 'Delete',
          isDestructive: true,
        );
        if (confirm && context.mounted) {
          context
              .read<MeasurementProvider>()
              .deleteProgressPhoto(userId, photo.id, photo.photoUrl);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              photo.photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppTheme.surfaceLight,
                child: const Icon(Icons.broken_image,
                    color: AppTheme.textMuted),
              ),
            ),
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  photo.type.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  final String type;
  final String userId;
  final MeasurementProvider provider;

  const _AddPhotoTile({
    required this.type,
    required this.userId,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickImage(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppTheme.textMuted.withOpacity(0.3),
              style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo_outlined,
                color: AppTheme.textMuted, size: 24),
            const SizedBox(height: 4),
            Text(
              type.toUpperCase(),
              style:
                  const TextStyle(color: AppTheme.textMuted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null || !context.mounted) return;

    final photoId = const Uuid().v4();
    await provider.uploadProgressPhoto(
      userId: userId,
      file: File(picked.path),
      photoType: type,
      photoId: photoId,
    );
  }
}

class _AddMeasurementSheet extends StatefulWidget {
  const _AddMeasurementSheet();

  @override
  State<_AddMeasurementSheet> createState() =>
      _AddMeasurementSheetState();
}

class _AddMeasurementSheetState extends State<_AddMeasurementSheet> {
  final _weightCtrl = TextEditingController();
  final _bodyFatCtrl = TextEditingController();
  final _chestCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _armsCtrl = TextEditingController();
  final _legsCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _weightCtrl.dispose();
    _bodyFatCtrl.dispose();
    _chestCtrl.dispose();
    _waistCtrl.dispose();
    _armsCtrl.dispose();
    _legsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = context.read<AuthProvider>().userId!;
    final m = BodyMeasurement(
      userId: userId,
      weight: double.parse(_weightCtrl.text),
      bodyFat: _bodyFatCtrl.text.isNotEmpty
          ? double.tryParse(_bodyFatCtrl.text)
          : null,
      chest: _chestCtrl.text.isNotEmpty
          ? double.tryParse(_chestCtrl.text)
          : null,
      waist: _waistCtrl.text.isNotEmpty
          ? double.tryParse(_waistCtrl.text)
          : null,
      arms: _armsCtrl.text.isNotEmpty
          ? double.tryParse(_armsCtrl.text)
          : null,
      legs: _legsCtrl.text.isNotEmpty
          ? double.tryParse(_legsCtrl.text)
          : null,
    );
    await context.read<MeasurementProvider>().saveMeasurement(m);
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
            const Text('Add Measurement',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _weightCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  const InputDecoration(labelText: 'Weight (kg) *'),
              validator: (v) => Validators.positiveNumber(v, 'Weight'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bodyFatCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Body Fat %'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _chestCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Chest (cm)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _waistCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Waist (cm)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _armsCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Arms (cm)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _legsCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  const InputDecoration(labelText: 'Legs (cm)'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save Measurement'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
