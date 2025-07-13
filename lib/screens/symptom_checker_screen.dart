import 'package:flutter/material.dart';
import '../models/period_data.dart';
import '../services/period_tracker_service.dart';

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final PeriodTrackerService _periodService = PeriodTrackerService();
  List<SymptomData> _symptoms = [];
  String _analysisResult = '';

  @override
  void initState() {
    super.initState();
    _loadSymptoms();
  }

  Future<void> _loadSymptoms() async {
    final symptoms = await _periodService.getAllSymptomData();
    setState(() {
      _symptoms = symptoms;
      _analysisResult = _periodService.analyzeSymptoms(symptoms);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom Checker'),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Analysis Result
            _buildAnalysisCard(),
            const SizedBox(height: 20),

            // Add Symptom Button
            _buildAddSymptomButton(),
            const SizedBox(height: 20),

            // Symptoms List
            _buildSymptomsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Color(0xFFFF9800)),
                const SizedBox(width: 8),
                Text(
                  'Health Analysis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getAnalysisColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getAnalysisColor()),
              ),
              child: Text(
                _analysisResult,
                style: TextStyle(
                  color: _getAnalysisColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAnalysisColor() {
    if (_analysisResult.contains('severe')) return Colors.red;
    if (_analysisResult.contains('moderate')) return Colors.orange;
    return Colors.green;
  }

  Widget _buildAddSymptomButton() {
    return ElevatedButton(
      onPressed: () => _showAddSymptomDialog(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFF9800),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(Icons.add), SizedBox(width: 8), Text('Add Symptom')],
      ),
    );
  }

  Widget _buildSymptomsList() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list, color: Color(0xFF4CAF50)),
                const SizedBox(width: 8),
                Text(
                  'Recent Symptoms',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_symptoms.isEmpty)
              Text('No symptoms recorded yet.')
            else
              ..._symptoms.reversed
                  .take(10)
                  .map(
                    (symptom) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getSeverityColor(symptom.severity),
                        child: Icon(
                          Icons.health_and_safety,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(symptom.name),
                      subtitle: Text(
                        '${_formatDate(symptom.date)} - ${symptom.severity}',
                      ),
                      trailing: symptom.description.isNotEmpty
                          ? Icon(Icons.info, color: Colors.blue)
                          : null,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'severe':
        return Colors.red;
      case 'moderate':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  void _showAddSymptomDialog() {
    String selectedSymptom = '';
    String selectedSeverity = 'mild';
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Symptom'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Symptom Selection
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Symptom'),
                value: selectedSymptom.isEmpty ? null : selectedSymptom,
                items:
                    [
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
                          'Heavy bleeding',
                          'Irregular periods',
                          'White discharge',
                          'Pain during intercourse',
                          'Urinary issues',
                        ]
                        .map(
                          (symptom) => DropdownMenuItem(
                            value: symptom,
                            child: Text(symptom),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  selectedSymptom = value!;
                },
              ),

              const SizedBox(height: 16),

              // Severity Selection
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Severity'),
                value: selectedSeverity,
                items: [
                  DropdownMenuItem(value: 'mild', child: Text('Mild')),
                  DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
                  DropdownMenuItem(value: 'severe', child: Text('Severe')),
                ],
                onChanged: (value) {
                  selectedSeverity = value!;
                },
              ),

              const SizedBox(height: 16),

              // Description
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
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
            onPressed: selectedSymptom.isNotEmpty
                ? () => _addSymptom(
                    selectedSymptom,
                    selectedSeverity,
                    descriptionController.text,
                  )
                : null,
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addSymptom(
    String name,
    String severity,
    String description,
  ) async {
    final symptomData = SymptomData(
      name: name,
      severity: severity,
      date: DateTime.now(),
      description: description,
    );

    await _periodService.saveSymptomData(symptomData);
    await _loadSymptoms();

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Symptom added successfully'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
