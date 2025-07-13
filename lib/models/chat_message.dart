enum MessageType { user, ai }

class ChatMessage {
  final String id;
  final String message;
  final MessageType type;
  final DateTime timestamp;
  final String? language; // for multilingual support
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.message,
    required this.type,
    required this.timestamp,
    this.language,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'language': language,
      'metadata': metadata,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      message: json['message'],
      type: MessageType.values.firstWhere((e) => e.toString() == json['type']),
      timestamp: DateTime.parse(json['timestamp']),
      language: json['language'],
      metadata: json['metadata'],
    );
  }
}

class HealthQuery {
  final String query;
  final String category; // period, pregnancy, symptoms, general
  final String severity; // low, medium, high, emergency
  final List<String> symptoms;
  final String language;

  HealthQuery({
    required this.query,
    required this.category,
    required this.severity,
    this.symptoms = const [],
    this.language = 'en',
  });
}

class AIResponse {
  final String response;
  final String category;
  final String severity;
  final List<String> recommendations;
  final bool requiresDoctorVisit;
  final String? emergencyMessage;

  AIResponse({
    required this.response,
    required this.category,
    required this.severity,
    required this.recommendations,
    this.requiresDoctorVisit = false,
    this.emergencyMessage,
  });
}
