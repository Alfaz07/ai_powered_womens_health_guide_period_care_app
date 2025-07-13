import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/period_data.dart';

class PeriodTrackerService {
  static const String _periodDataKey = 'period_data';
  static const String _symptomsKey = 'symptoms_data';

  // Save period data
  Future<void> savePeriodData(PeriodData periodData) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> periodDataList =
        prefs.getStringList(_periodDataKey) ?? [];

    // Add new period data
    periodDataList.add(jsonEncode(periodData.toJson()));

    // Keep only last 12 periods for analysis
    if (periodDataList.length > 12) {
      periodDataList.removeAt(0);
    }

    await prefs.setStringList(_periodDataKey, periodDataList);
  }

  // Get all period data
  Future<List<PeriodData>> getAllPeriodData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> periodDataList =
        prefs.getStringList(_periodDataKey) ?? [];

    return periodDataList
        .map((json) => PeriodData.fromJson(jsonDecode(json)))
        .toList();
  }

  // Predict next period
  CyclePrediction predictNextPeriod(List<PeriodData> periodHistory) {
    if (periodHistory.isEmpty) {
      return CyclePrediction(
        predictedStartDate: DateTime.now().add(const Duration(days: 28)),
        fertileWindowStart: DateTime.now().add(const Duration(days: 14)),
        fertileWindowEnd: DateTime.now().add(const Duration(days: 18)),
        ovulationDate: DateTime.now().add(const Duration(days: 16)),
        status: 'regular',
      );
    }

    // Calculate average cycle length
    int totalDays = 0;
    int cycleCount = 0;

    for (int i = 1; i < periodHistory.length; i++) {
      final days = periodHistory[i].startDate
          .difference(periodHistory[i - 1].startDate)
          .inDays;
      totalDays += days;
      cycleCount++;
    }

    final averageCycleLength = cycleCount > 0 ? totalDays ~/ cycleCount : 28;
    final lastPeriodDate = periodHistory.last.startDate;
    final predictedStartDate = lastPeriodDate.add(
      Duration(days: averageCycleLength),
    );

    // Calculate fertile window (typically 5 days before ovulation)
    final ovulationDate = predictedStartDate.subtract(const Duration(days: 14));
    final fertileWindowStart = ovulationDate.subtract(const Duration(days: 5));
    final fertileWindowEnd = ovulationDate.add(const Duration(days: 1));

    // Determine cycle status
    String status = 'regular';
    if (averageCycleLength < 21 || averageCycleLength > 35) {
      status = 'irregular';
    }

    return CyclePrediction(
      predictedStartDate: predictedStartDate,
      fertileWindowStart: fertileWindowStart,
      fertileWindowEnd: fertileWindowEnd,
      ovulationDate: ovulationDate,
      status: status,
    );
  }

  // Save symptom data
  Future<void> saveSymptomData(SymptomData symptomData) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> symptomsList = prefs.getStringList(_symptomsKey) ?? [];

    symptomsList.add(jsonEncode(symptomData.toJson()));

    // Keep only last 30 symptoms
    if (symptomsList.length > 30) {
      symptomsList.removeAt(0);
    }

    await prefs.setStringList(_symptomsKey, symptomsList);
  }

  // Get all symptom data
  Future<List<SymptomData>> getAllSymptomData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> symptomsList = prefs.getStringList(_symptomsKey) ?? [];

    return symptomsList
        .map((json) => SymptomData.fromJson(jsonDecode(json)))
        .toList();
  }

  // Analyze symptoms and provide recommendations
  String analyzeSymptoms(List<SymptomData> symptoms) {
    if (symptoms.isEmpty) return 'No symptoms recorded yet.';

    final recentSymptoms = symptoms
        .where((s) => DateTime.now().difference(s.date).inDays <= 7)
        .toList();

    if (recentSymptoms.isEmpty) return 'No recent symptoms recorded.';

    final severeSymptoms = recentSymptoms
        .where((s) => s.severity == 'severe')
        .toList();
    final moderateSymptoms = recentSymptoms
        .where((s) => s.severity == 'moderate')
        .toList();

    if (severeSymptoms.isNotEmpty) {
      return '⚠️ You have severe symptoms. Please consult a doctor immediately.';
    } else if (moderateSymptoms.isNotEmpty) {
      return '⚠️ You have moderate symptoms. Consider consulting a doctor if they persist.';
    } else {
      return '✅ Your symptoms are mild. Continue monitoring and maintain good hygiene.';
    }
  }

  // Get privacy-friendly reminder message
  String getPrivacyReminder(DateTime predictedDate) {
    final daysUntilPeriod = predictedDate.difference(DateTime.now()).inDays;

    if (daysUntilPeriod <= 0) {
      return 'Stay hydrated and take care of yourself today! 💧';
    } else if (daysUntilPeriod <= 3) {
      return 'Remember to drink warm water and rest well! 🫖';
    } else if (daysUntilPeriod <= 7) {
      return 'Keep yourself hydrated and maintain good nutrition! 🥗';
    } else {
      return 'Stay healthy and active! 💪';
    }
  }
}
