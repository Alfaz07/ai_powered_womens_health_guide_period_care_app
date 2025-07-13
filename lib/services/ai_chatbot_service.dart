import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class AIChatbotService {
  // For demo purposes, we'll use a simple rule-based system
  // In production, this would connect to GPT API or Dialogflow

  static const Map<String, Map<String, String>> _healthResponses = {
    'period_delay': {
      'en':
          'A period delay of 1-7 days is usually normal due to stress, diet changes, or hormonal fluctuations. If delayed by more than 10 days, consider taking a pregnancy test or consulting a doctor.',
      'hi':
          'पीरियड में 1-7 दिन की देरी आमतौर पर सामान्य है। तनाव, आहार में बदलाव या हार्मोनल उतार-चढ़ाव के कारण हो सकता है। अगर 10 दिन से ज्यादा देरी हो तो प्रेगनेंसी टेस्ट करें या डॉक्टर से सलाह लें।',
      'ml':
          '1-7 ദിവസം വൈകിയ വാരം സാധാരണമാണ്. സമ്മർദ്ദം, ഭക്ഷണ മാറ്റങ്ങൾ, ഹോർമോൺ മാറ്റങ്ങൾ കാരണം. 10 ദിവസത്തിൽ കൂടുതൽ വൈകിയാൽ ഗർഭ പരിശോധന ചെയ്യുകയോ വൈദ്യനെ കാണുകയോ ചെയ്യുക.',
    },
    'white_discharge': {
      'en':
          'White discharge is usually normal and helps keep the vagina clean. However, if it\'s thick, has a strong odor, or causes itching, it might indicate an infection. Consult a doctor if concerned.',
      'hi':
          'सफेद स्राव आमतौर पर सामान्य है और योनि को साफ रखने में मदद करता है। लेकिन अगर यह गाढ़ा है, तेज गंध है या खुजली होती है तो संक्रमण हो सकता है। चिंता हो तो डॉक्टर से सलाह लें।',
      'ml':
          'വെള്ള സ്രാവം സാധാരണമാണ്, യോനി ശുദ്ധമായി സൂക്ഷിക്കാൻ സഹായിക്കുന്നു. എന്നാൽ കട്ടിയുള്ളതാണെങ്കിൽ, ശക്തമായ മണമുണ്ടെങ്കിൽ, ചൊറിച്ചിൽ ഉണ്ടെങ്കിൽ രോഗാണുസംക്രമണം ആകാം. ആശങ്കയുണ്ടെങ്കിൽ വൈദ്യനെ കാണുക.',
    },
    'period_pain': {
      'en':
          'Period pain is common. Try warm water, rest, gentle exercise, and over-the-counter pain relievers. If pain is severe or lasts more than 3 days, consult a doctor.',
      'hi':
          'पीरियड में दर्द आम है। गर्म पानी, आराम, हल्का व्यायाम और दर्द निवारक दवाएं आज़माएं। अगर दर्द तेज है या 3 दिन से ज्यादा रहता है तो डॉक्टर से सलाह लें।',
      'ml':
          'വാരത്തിൽ വേദന സാധാരണമാണ്. ചൂടുവെള്ളം, വിശ്രമം, ലഘു വ്യായാമം, വേദനാ ശമന മരുന്നുകൾ ഉപയോഗിക്കുക. വേദന കഠിനമാണെങ്കിലോ 3 ദിവസത്തിൽ കൂടുതൽ നീണ്ടാൽ വൈദ്യനെ കാണുക.',
    },
    'heavy_bleeding': {
      'en':
          'Heavy bleeding can be normal for some women, but if you\'re changing pads every 1-2 hours or bleeding lasts more than 7 days, consult a doctor immediately.',
      'hi':
          'तेज रक्तस्राव कुछ महिलाओं के लिए सामान्य हो सकता है, लेकिन अगर आप हर 1-2 घंटे में पैड बदल रही हैं या 7 दिन से ज्यादा रक्तस्राव हो रहा है तो तुरंत डॉक्टर से सलाह लें।',
      'ml':
          'കടുത്ത രക്തസ്രാവം ചില സ്ത്രീകൾക്ക് സാധാരണമാകാം, എന്നാൽ 1-2 മണിക്കൂർ마다 പാഡ് മാറ്റുന്നുണ്ടെങ്കിലോ 7 ദിവസത്തിൽ കൂടുതൽ രക്തസ്രാവം നീണ്ടാൽ ഉടൻ വൈദ്യനെ കാണുക.',
    },
    'pregnancy_nutrition': {
      'en':
          'During pregnancy, eat a balanced diet rich in iron, calcium, protein, and folic acid. Include fruits, vegetables, whole grains, and lean proteins. Avoid raw fish, unpasteurized dairy, and excessive caffeine.',
      'hi':
          'गर्भावस्था के दौरान, लोहा, कैल्शियम, प्रोटीन और फोलिक एसिड से भरपूर संतुलित आहार लें। फल, सब्जियां, साबुत अनाज और दुबला प्रोटीन शामिल करें। कच्ची मछली, बिना पाश्चराइज्ड डेयरी और अधिक कैफीन से बचें।',
      'ml':
          'ഗർഭകാലത്ത് ഇരുമ്പ്, കാൽസ്യം, പ്രോട്ടീൻ, ഫോളിക് ആസിഡ് ധാരാളമുള്ള സന്തുലിത ഭക്ഷണം കഴിക്കുക. പഴങ്ങൾ, പച്ചക്കറികൾ, മുഴുവൻ ധാന്യങ്ങൾ, ദുർബല പ്രോട്ടീനുകൾ ഉൾപ്പെടുത്തുക. അസംസ്കൃത മത്സ്യം, പാസ്ചറൈസ് ചെയ്യാത്ത പാൽ ഉൽപ്പന്നങ്ങൾ, അധിക കാഫീൻ ഒഴിവാക്കുക.',
    },
  };

  static const Map<String, List<String>> _keywords = {
    'period_delay': [
      'delay',
      'late',
      'missed',
      'overdue',
      'विलंब',
      'देरी',
      'വൈകി',
    ],
    'white_discharge': [
      'white',
      'discharge',
      'leucorrhoea',
      'सफेद',
      'स्राव',
      'വെള്ള',
      'സ്രാവം',
    ],
    'period_pain': ['pain', 'cramps', 'ache', 'दर्द', 'मरोड़', 'വേദന', 'മരോഡ്'],
    'heavy_bleeding': [
      'heavy',
      'bleeding',
      'flow',
      'तेज',
      'रक्तस्राव',
      'കടുത്ത',
      'രക്തസ്രാവം',
    ],
    'pregnancy_nutrition': [
      'pregnancy',
      'pregnant',
      'nutrition',
      'food',
      'diet',
      'गर्भावस्था',
      'गर्भ',
      'ഗർഭം',
      'ഭക്ഷണം',
    ],
  };

  // Analyze user query and determine category
  String _analyzeQuery(String query, String language) {
    query = query.toLowerCase();

    for (String category in _keywords.keys) {
      for (String keyword in _keywords[category]!) {
        if (query.contains(keyword)) {
          return category;
        }
      }
    }

    return 'general';
  }

  // Get AI response based on query
  Future<AIResponse> getResponse(String query, String language) async {
    final category = _analyzeQuery(query, language);

    if (_healthResponses.containsKey(category)) {
      final response =
          _healthResponses[category]![language] ??
          _healthResponses[category]!['en']!;

      return AIResponse(
        response: response,
        category: category,
        severity: _getSeverity(category),
        recommendations: _getRecommendations(category),
        requiresDoctorVisit: _requiresDoctorVisit(category),
        emergencyMessage: _getEmergencyMessage(category),
      );
    }

    // Default response for unrecognized queries
    return AIResponse(
      response: language == 'hi'
          ? 'मैं आपकी मदद करने की कोशिश कर रही हूं। कृपया अपने लक्षणों के बारे में और विस्तार से बताएं।'
          : language == 'ml'
          ? 'നിങ്ങളെ സഹായിക്കാൻ ശ്രമിക്കുന്നു. ദയവായി നിങ്ങളുടെ ലക്ഷണങ്ങളെക്കുറിച്ച് കൂടുതൽ വിവരങ്ങൾ നൽകുക.'
          : 'I\'m trying to help you. Please provide more details about your symptoms.',
      category: 'general',
      severity: 'low',
      recommendations: [
        'Consult a healthcare provider for personalized advice',
      ],
      requiresDoctorVisit: false,
    );
  }

  String _getSeverity(String category) {
    switch (category) {
      case 'heavy_bleeding':
        return 'high';
      case 'period_pain':
        return 'medium';
      default:
        return 'low';
    }
  }

  List<String> _getRecommendations(String category) {
    switch (category) {
      case 'period_delay':
        return [
          'Reduce stress through meditation or yoga',
          'Maintain a regular sleep schedule',
          'Eat a balanced diet',
          'Exercise regularly',
        ];
      case 'period_pain':
        return [
          'Apply warm compress to lower abdomen',
          'Take warm baths',
          'Practice gentle stretching',
          'Stay hydrated',
        ];
      case 'heavy_bleeding':
        return [
          'Rest more during heavy flow days',
          'Stay hydrated',
          'Eat iron-rich foods',
          'Monitor your symptoms',
        ];
      default:
        return [
          'Maintain good hygiene',
          'Stay hydrated',
          'Get adequate rest',
          'Eat a balanced diet',
        ];
    }
  }

  bool _requiresDoctorVisit(String category) {
    return category == 'heavy_bleeding';
  }

  String? _getEmergencyMessage(String category) {
    if (category == 'heavy_bleeding') {
      return '⚠️ If you\'re changing pads every 1-2 hours, seek immediate medical attention.';
    }
    return null;
  }

  // Save chat message
  Future<void> saveChatMessage(ChatMessage message) async {
    // In a real app, this would save to local database
    // For now, we'll just print for demo
    print('Saving chat message: ${message.message}');
  }

  // Get chat history
  Future<List<ChatMessage>> getChatHistory() async {
    // In a real app, this would load from local database
    return [];
  }
}
