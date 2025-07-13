import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/period_data.dart';
import '../services/period_tracker_service.dart';

class PeriodTrackerScreen extends StatefulWidget {
  const PeriodTrackerScreen({super.key});

  @override
  State<PeriodTrackerScreen> createState() => _PeriodTrackerScreenState();
}

class _PeriodTrackerScreenState extends State<PeriodTrackerScreen> {
  final PeriodTrackerService _periodService = PeriodTrackerService();
  List<PeriodData> _periodHistory = [];
  CyclePrediction? _prediction;
  DateTime? _selectedDate;
  String _selectedFlow = 'medium';
  List<String> _selectedSymptoms = [];
  final TextEditingController _notesController = TextEditingController();

  final List<String> _flowOptions = ['light', 'medium', 'heavy'];
  final List<String> _symptomOptions = [
    'Cramps',
    'Bloating',
    'Fatigue',
    'Mood swings',
    'Breast tenderness',
    'Headache',
    'Back pain',
    'Acne',
    'Food cravings',
    'Insomnia',
  ];

  @override
  void initState() {
    super.initState();
    _loadPeriodData();
  }

  Future<void> _loadPeriodData() async {
    final history = await _periodService.getAllPeriodData();
    setState(() {
      _periodHistory = history;
      if (history.isNotEmpty) {
        _prediction = _periodService.predictNextPeriod(history);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Period Tracker'),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Status Card
            _buildStatusCard(),
            const SizedBox(height: 20),

            // Add Period Button
            _buildAddPeriodButton(),
            const SizedBox(height: 20),

            // Prediction Card
            if (_prediction != null) _buildPredictionCard(),
            const SizedBox(height: 20),

            // Period History
            _buildHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Color(0xFFE91E63)),
                const SizedBox(width: 8),
                Text(
                  'Current Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_prediction != null) ...[
              Text(
                'Next period: ${_formatDate(_prediction!.predictedStartDate)}',
              ),
              Text('Cycle status: ${_prediction!.status}'),
              Text(
                'Fertile window: ${_formatDate(_prediction!.fertileWindowStart)} - ${_formatDate(_prediction!.fertileWindowEnd)}',
              ),
            ] else ...[
              Text('No period data recorded yet.'),
              Text('Add your first period to start tracking.'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddPeriodButton() {
    return ElevatedButton(
      onPressed: () => _showAddPeriodDialog(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFE91E63),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(Icons.add), SizedBox(width: 8), Text('Add Period')],
      ),
    );
  }

  Widget _buildPredictionCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Color(0xFF9C27B0)),
                const SizedBox(width: 8),
                Text(
                  'AI Prediction',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Predicted start: ${_formatDate(_prediction!.predictedStartDate)}',
            ),
            Text('Ovulation: ${_formatDate(_prediction!.ovulationDate)}'),
            Text('Status: ${_prediction!.status}'),
            const SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFE91E63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _periodService.getPrivacyReminder(
                  _prediction!.predictedStartDate,
                ),
                style: TextStyle(
                  color: Color(0xFFE91E63),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Color(0xFF4CAF50)),
                const SizedBox(width: 8),
                Text(
                  'Period History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_periodHistory.isEmpty)
              Text('No period history yet.')
            else
              ..._periodHistory.reversed
                  .take(6)
                  .map(
                    (period) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFFE91E63),
                        child: Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text('${_formatDate(period.startDate)}'),
                      subtitle: Text(
                        'Flow: ${period.flow} | Cycle: ${period.cycleLength} days',
                      ),
                      trailing: period.symptoms.isNotEmpty
                          ? Icon(Icons.info, color: Colors.orange)
                          : null,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _showAddPeriodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Period'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date Picker
              ListTile(
                title: Text('Start Date'),
                subtitle: Text(
                  _selectedDate != null
                      ? _formatDate(_selectedDate!)
                      : 'Select date',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
              ),

              // Flow Selection
              ListTile(
                title: Text('Flow'),
                subtitle: DropdownButton<String>(
                  value: _selectedFlow,
                  items: _flowOptions
                      .map(
                        (flow) =>
                            DropdownMenuItem(value: flow, child: Text(flow)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedFlow = value!);
                  },
                ),
              ),

              // Symptoms Selection
              ListTile(
                title: Text('Symptoms'),
                subtitle: Wrap(
                  spacing: 8,
                  children: _symptomOptions
                      .map(
                        (symptom) => FilterChip(
                          label: Text(symptom),
                          selected: _selectedSymptoms.contains(symptom),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSymptoms.add(symptom);
                              } else {
                                _selectedSymptoms.remove(symptom);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              ),

              // Notes
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _selectedDate != null ? () => _addPeriod() : null,
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addPeriod() async {
    if (_selectedDate == null) return;

    final periodData = PeriodData(
      startDate: _selectedDate!,
      cycleLength: _calculateCycleLength(),
      symptoms: _selectedSymptoms,
      flow: _selectedFlow,
      notes: _notesController.text,
    );

    await _periodService.savePeriodData(periodData);
    await _loadPeriodData();

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Period added successfully'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );

    // Reset form
    setState(() {
      _selectedDate = null;
      _selectedFlow = 'medium';
      _selectedSymptoms.clear();
      _notesController.clear();
    });
  }

  int _calculateCycleLength() {
    if (_periodHistory.isEmpty) return 28; // Default cycle length

    final lastPeriod = _periodHistory.last;
    return _selectedDate!.difference(lastPeriod.startDate).inDays;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
