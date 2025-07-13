class PeriodData {
  final DateTime startDate;
  final DateTime? endDate;
  final int cycleLength;
  final List<String> symptoms;
  final String flow; // light, medium, heavy
  final String notes;

  PeriodData({
    required this.startDate,
    this.endDate,
    required this.cycleLength,
    this.symptoms = const [],
    this.flow = 'medium',
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'cycleLength': cycleLength,
      'symptoms': symptoms,
      'flow': flow,
      'notes': notes,
    };
  }

  factory PeriodData.fromJson(Map<String, dynamic> json) {
    return PeriodData(
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      cycleLength: json['cycleLength'],
      symptoms: List<String>.from(json['symptoms']),
      flow: json['flow'],
      notes: json['notes'],
    );
  }
}

class CyclePrediction {
  final DateTime predictedStartDate;
  final DateTime fertileWindowStart;
  final DateTime fertileWindowEnd;
  final DateTime ovulationDate;
  final String status; // regular, irregular, late

  CyclePrediction({
    required this.predictedStartDate,
    required this.fertileWindowStart,
    required this.fertileWindowEnd,
    required this.ovulationDate,
    required this.status,
  });
}

class SymptomData {
  final String name;
  final String severity; // mild, moderate, severe
  final DateTime date;
  final String description;

  SymptomData({
    required this.name,
    required this.severity,
    required this.date,
    this.description = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'severity': severity,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory SymptomData.fromJson(Map<String, dynamic> json) {
    return SymptomData(
      name: json['name'],
      severity: json['severity'],
      date: DateTime.parse(json['date']),
      description: json['description'],
    );
  }
}
