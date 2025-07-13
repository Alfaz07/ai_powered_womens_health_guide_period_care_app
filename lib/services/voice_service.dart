import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _speechEnabled = false;

  // Initialize speech recognition
  Future<bool> initializeSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (error) => print('Speech recognition error: $error'),
        onStatus: (status) => print('Speech recognition status: $status'),
      );
      return _speechEnabled;
    } catch (e) {
      print('Error initializing speech recognition: $e');
      return false;
    }
  }

  // Initialize text-to-speech
  Future<void> initializeTTS() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
    } catch (e) {
      print('Error initializing TTS: $e');
    }
  }

  // Set language for TTS
  Future<void> setLanguage(String languageCode) async {
    try {
      switch (languageCode) {
        case 'hi':
          await _flutterTts.setLanguage('hi-IN');
          break;
        case 'ml':
          await _flutterTts.setLanguage('ml-IN');
          break;
        default:
          await _flutterTts.setLanguage('en-US');
      }
    } catch (e) {
      print('Error setting language: $e');
    }
  }

  // Start listening for speech
  Future<void> startListening({
    required Function(String text) onResult,
    required Function(String error) onError,
  }) async {
    if (!_speechEnabled) {
      onError('Speech recognition not available');
      return;
    }

    try {
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: false,
        localeId: 'en_US', // Can be made configurable
      );
    } catch (e) {
      onError('Error starting speech recognition: $e');
    }
  }

  // Stop listening
  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
    } catch (e) {
      print('Error stopping speech recognition: $e');
    }
  }

  // Speak text
  Future<void> speak(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('Error speaking text: $e');
    }
  }

  // Stop speaking
  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('Error stopping TTS: $e');
    }
  }

  // Check if speech is available
  bool get isSpeechAvailable => _speechEnabled;

  // Get privacy-friendly voice prompts
  Map<String, String> getPrivacyPrompts() {
    return {
      'en': 'How can I help you today?',
      'hi': 'मैं आज आपकी कैसे मदद कर सकती हूं?',
      'ml': 'ഇന്ന് എനിക്ക് നിങ്ങളെ എങ്ങനെ സഹായിക്കാനാകും?',
    };
  }

  // Get voice confirmation messages
  Map<String, String> getConfirmationMessages() {
    return {
      'en': 'I understand. Let me help you with that.',
      'hi': 'मैं समझ गई। मैं आपकी मदद करती हूं।',
      'ml': 'ഞാൻ മനസ്സിലാക്കി. എനിക്ക് നിങ്ങളെ സഹായിക്കാം.',
    };
  }

  // Get emergency voice messages
  Map<String, String> getEmergencyMessages() {
    return {
      'en':
          'This may require immediate medical attention. Please consult a doctor.',
      'hi':
          'इसके लिए तुरंत चिकित्सकीय सहायता की आवश्यकता हो सकती है। कृपया डॉक्टर से सलाह लें।',
      'ml':
          'ഇതിന് ഉടൻ മെഡിക്കൽ ശ്രദ്ധ ആവശ്യമായി വരാം. ദയവായി ഒരു വൈദ്യനെ കാണുക.',
    };
  }
}
