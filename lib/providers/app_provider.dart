import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  String _currentLanguage = 'en';
  bool _isVoiceEnabled = false;
  bool _isDarkMode = false;
  String _userName = '';

  // Getters
  String get currentLanguage => _currentLanguage;
  bool get isVoiceEnabled => _isVoiceEnabled;
  bool get isDarkMode => _isDarkMode;
  String get userName => _userName;

  // Initialize app settings
  Future<void> initializeApp() async {
    await _loadSettings();
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString('language') ?? 'en';
      _isVoiceEnabled = prefs.getBool('voice_enabled') ?? false;
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _userName = prefs.getString('user_name') ?? '';
      notifyListeners();
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', _currentLanguage);
      await prefs.setBool('voice_enabled', _isVoiceEnabled);
      await prefs.setBool('dark_mode', _isDarkMode);
      await prefs.setString('user_name', _userName);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  // Set language
  Future<void> setLanguage(String language) async {
    _currentLanguage = language;
    await _saveSettings();
    notifyListeners();
  }

  // Toggle voice mode
  Future<void> toggleVoiceMode() async {
    _isVoiceEnabled = !_isVoiceEnabled;
    await _saveSettings();
    notifyListeners();
  }

  // Toggle dark mode
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _saveSettings();
    notifyListeners();
  }

  // Set user name
  Future<void> setUserName(String name) async {
    _userName = name;
    await _saveSettings();
    notifyListeners();
  }

  // Get localized text
  String getLocalizedText(Map<String, String> texts) {
    return texts[_currentLanguage] ?? texts['en'] ?? '';
  }

  // Get supported languages
  List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'en', 'name': 'English', 'native': 'English'},
      {'code': 'hi', 'name': 'Hindi', 'native': 'हिंदी'},
      {'code': 'ml', 'name': 'Malayalam', 'native': 'മലയാളം'},
    ];
  }

  // Get language name by code
  String getLanguageName(String code) {
    final languages = getSupportedLanguages();
    final language = languages.firstWhere(
      (lang) => lang['code'] == code,
      orElse: () => {'name': 'English', 'native': 'English'},
    );
    return language['native'] ?? 'English';
  }
}
