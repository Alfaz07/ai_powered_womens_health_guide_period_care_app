import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/pregnancy_data.dart';
import '../services/pregnancy_tracker_service.dart';

class PregnancyTrackerScreen extends StatefulWidget {
  const PregnancyTrackerScreen({super.key});

  @override
  State<PregnancyTrackerScreen> createState() => _PregnancyTrackerScreenState();
}

class _PregnancyTrackerScreenState extends State<PregnancyTrackerScreen> {
  final PregnancyTrackerService _pregnancyService = PregnancyTrackerService();
  PregnancyData? _pregnancyData;
  WeeklyPregnancyInfo? _weeklyInfo;
  DateTime? _lastPeriodDate;
  DateTime? _dueDate;
  int _currentWeek = 0;

  @override
  void initState() {
    super.initState();
    _loadPregnancyData();
  }

  Future<void> _loadPregnancyData() async {
    final data = await _pregnancyService.getPregnancyData();
    setState(() {
      _pregnancyData = data;
      if (data != null) {
        _lastPeriodDate = data.lastPeriodDate;
        _dueDate = data.dueDate;
        _currentWeek = data.currentWeek;
        _weeklyInfo = _pregnancyService.getWeeklyInfo(_currentWeek);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregnancy Tracker'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Setup Section
            if (_pregnancyData == null) _buildSetupSection(),

            // Current Status
            if (_pregnancyData != null) ...[
              _buildCurrentStatusCard(),
              const SizedBox(height: 20),

              // Weekly Information
              if (_weeklyInfo != null) _buildWeeklyInfoCard(),
              const SizedBox(height: 20),

              // Nutrition Tips
              _buildNutritionTipsCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSetupSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: Color(0xFF4CAF50)),
                const SizedBox(width: 8),
                Text(
                  'Start Pregnancy Tracking',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Enter your last period date to start tracking your pregnancy journey.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showSetupDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text('Set Last Period Date'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pregnant_woman, color: Color(0xFF4CAF50)),
                const SizedBox(width: 8),
                Text(
                  'Current Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Week: $_currentWeek'),
            Text('Due Date: ${_formatDate(_dueDate!)}'),
            Text('Trimester: ${_getTrimester(_currentWeek)}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _currentWeek / 40,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
            Text('${_currentWeek}/40 weeks completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Color(0xFF2196F3)),
                const SizedBox(width: 8),
                Text(
                  'Week $_currentWeek Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Baby Development
            _buildInfoSection(
              'Baby Development',
              _weeklyInfo!.babyDevelopment,
              Icons.child_care,
            ),
            const SizedBox(height: 8),

            // Mother Changes
            _buildInfoSection(
              'Your Changes',
              _weeklyInfo!.motherChanges,
              Icons.pregnant_woman,
            ),
            const SizedBox(height: 8),

            // Symptoms
            _buildInfoSection(
              'Common Symptoms',
              _weeklyInfo!.symptoms.join(', '),
              Icons.health_and_safety,
            ),
            const SizedBox(height: 8),

            // Precautions
            _buildInfoSection(
              'Precautions',
              _weeklyInfo!.precautions.join('\n'),
              Icons.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Color(0xFF2196F3)),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(content),
      ],
    );
  }

  Widget _buildNutritionTipsCard() {
    final nutritionTips = _pregnancyService.getNutritionTips();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, color: Color(0xFFFF9800)),
                const SizedBox(width: 8),
                Text(
                  'Nutrition Tips',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...nutritionTips.map((tip) => _buildNutritionTip(tip)),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionTip(NutritionTip tip) {
    return ExpansionTile(
      title: Text(tip.title),
      subtitle: Text(tip.description),
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight:
                200, // Prevents overflow, allows scroll if content is large
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Food Sources:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: tip.foodItems
                        .map(
                          (food) => Chip(
                            label: Text(food),
                            backgroundColor: Color(0xFFFF9800).withOpacity(0.1),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Last Period Date'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('When was your last period?'),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Last Period Date'),
              subtitle: Text(
                _lastPeriodDate != null
                    ? _formatDate(_lastPeriodDate!)
                    : 'Select date',
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().subtract(Duration(days: 14)),
                  firstDate: DateTime.now().subtract(Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _lastPeriodDate = date);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed:
                _lastPeriodDate != null ? () => _savePregnancyData() : null,
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _savePregnancyData() async {
    if (_lastPeriodDate == null) return;

    final currentWeek = _pregnancyService.calculateCurrentWeek(
      _lastPeriodDate!,
    );
    final dueDate = _pregnancyService.calculateDueDate(_lastPeriodDate!);

    final pregnancyData = PregnancyData(
      lastPeriodDate: _lastPeriodDate!,
      dueDate: dueDate,
      currentWeek: currentWeek,
      trimester: _getTrimester(currentWeek),
    );

    await _pregnancyService.savePregnancyData(pregnancyData);
    await _loadPregnancyData();

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pregnancy tracking started!'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  String _getTrimester(int week) {
    if (week <= 12) return 'first';
    if (week <= 28) return 'second';
    return 'third';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
