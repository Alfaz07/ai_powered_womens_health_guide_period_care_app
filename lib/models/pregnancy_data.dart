class PregnancyData {
  final DateTime lastPeriodDate;
  final DateTime? dueDate;
  final int currentWeek;
  final String trimester; // first, second, third
  final List<String> symptoms;
  final List<String> nutritionTips;
  final List<String> precautions;

  PregnancyData({
    required this.lastPeriodDate,
    this.dueDate,
    required this.currentWeek,
    required this.trimester,
    this.symptoms = const [],
    this.nutritionTips = const [],
    this.precautions = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'lastPeriodDate': lastPeriodDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'currentWeek': currentWeek,
      'trimester': trimester,
      'symptoms': symptoms,
      'nutritionTips': nutritionTips,
      'precautions': precautions,
    };
  }

  factory PregnancyData.fromJson(Map<String, dynamic> json) {
    return PregnancyData(
      lastPeriodDate: DateTime.parse(json['lastPeriodDate']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      currentWeek: json['currentWeek'],
      trimester: json['trimester'],
      symptoms: List<String>.from(json['symptoms']),
      nutritionTips: List<String>.from(json['nutritionTips']),
      precautions: List<String>.from(json['precautions']),
    );
  }
}

class WeeklyPregnancyInfo {
  final int week;
  final String babyDevelopment;
  final String motherChanges;
  final List<String> nutritionTips;
  final List<String> precautions;
  final List<String> symptoms;

  WeeklyPregnancyInfo({
    required this.week,
    required this.babyDevelopment,
    required this.motherChanges,
    required this.nutritionTips,
    required this.precautions,
    required this.symptoms,
  });
}

class NutritionTip {
  final String title;
  final String description;
  final String category; // iron, calcium, protein, etc.
  final List<String> foodItems;

  NutritionTip({
    required this.title,
    required this.description,
    required this.category,
    required this.foodItems,
  });
}
