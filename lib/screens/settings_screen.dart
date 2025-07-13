import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF607D8B),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Language Settings
              _buildSectionCard(
                title: 'Language Settings',
                icon: Icons.language,
                children: [
                  ListTile(
                    title: Text('App Language'),
                    subtitle: Text(
                      appProvider.getLanguageName(appProvider.currentLanguage),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () => _showLanguageDialog(context, appProvider),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Voice Settings
              _buildSectionCard(
                title: 'Voice Settings',
                icon: Icons.mic,
                children: [
                  SwitchListTile(
                    title: Text('Voice Mode'),
                    subtitle: Text('Enable voice input and output'),
                    value: appProvider.isVoiceEnabled,
                    onChanged: (value) {
                      appProvider.toggleVoiceMode();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Appearance Settings
              _buildSectionCard(
                title: 'Appearance',
                icon: Icons.palette,
                children: [
                  SwitchListTile(
                    title: Text('Dark Mode'),
                    subtitle: Text('Use dark theme'),
                    value: appProvider.isDarkMode,
                    onChanged: (value) {
                      appProvider.toggleDarkMode();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Privacy Settings
              _buildSectionCard(
                title: 'Privacy & Security',
                icon: Icons.security,
                children: [
                  ListTile(
                    title: Text('Data Privacy'),
                    subtitle: Text('All data is stored locally on your device'),
                    leading: Icon(Icons.check_circle, color: Colors.green),
                  ),
                  ListTile(
                    title: Text('Export Data'),
                    subtitle: Text('Export your health data'),
                    trailing: Icon(Icons.download),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Export feature coming soon')),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Clear All Data'),
                    subtitle: Text('Delete all stored data'),
                    trailing: Icon(Icons.delete_forever, color: Colors.red),
                    onTap: () => _showClearDataDialog(context),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // About Section
              _buildSectionCard(
                title: 'About',
                icon: Icons.info,
                children: [
                  ListTile(title: Text('App Version'), subtitle: Text('1.0.0')),
                  ListTile(
                    title: Text('SakhiCare'),
                    subtitle: Text('AI-Powered Women\'s Health Guide'),
                  ),
                  ListTile(
                    title: Text('Privacy Policy'),
                    trailing: Icon(Icons.open_in_new),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Privacy policy coming soon')),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Terms of Service'),
                    trailing: Icon(Icons.open_in_new),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Terms of service coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Color(0xFF607D8B)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, AppProvider appProvider) {
    final languages = appProvider.getSupportedLanguages();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages
              .map(
                (language) => ListTile(
                  title: Text(language['native']!),
                  subtitle: Text(language['name']!),
                  trailing: appProvider.currentLanguage == language['code']
                      ? Icon(Icons.check, color: Color(0xFF4CAF50))
                      : null,
                  onTap: () {
                    appProvider.setLanguage(language['code']!);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Data'),
        content: Text(
          'This will permanently delete all your health data including period history, symptoms, and pregnancy information. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Clear data logic would go here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All data cleared'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Clear Data'),
          ),
        ],
      ),
    );
  }
}
