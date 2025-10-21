import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = 'English';
  bool _isLoading = true;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'native': 'English', 'flag': '🇬🇧'},
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिंदी', 'flag': '🇮🇳'},
    {'code': 'bn', 'name': 'Bengali', 'native': 'বাংলা', 'flag': '🇧🇩'},
    {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்', 'flag': '🇮🇳'},
    {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు', 'flag': '🇮🇳'},
    {'code': 'mr', 'name': 'Marathi', 'native': 'मराठी', 'flag': '🇮🇳'},
    {'code': 'gu', 'name': 'Gujarati', 'native': 'ગુજરાતી', 'flag': '🇮🇳'},
    {'code': 'kn', 'name': 'Kannada', 'native': 'ಕನ್ನಡ', 'flag': '🇮🇳'},
  ];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _selectedLanguage = prefs.getString('language') ?? 'English';
      });
    } catch (e) {
      debugPrint('Error loading language: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveLanguage(String languageName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageName);

      setState(() {
        _selectedLanguage = languageName;
      });

      if (mounted) {
        // Show dialog about app restart
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.language, color: Colors.blue),
                SizedBox(width: 8),
                Text('Language Changed'),
              ],
            ),
            content: const Text(
              'Your language preference has been saved.\n\nNote: Full language support coming soon! Currently, the app interface will remain in English, but your preference is saved for future updates.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header
                FadeInDown(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.language, size: 48, color: Colors.white),
                        SizedBox(height: 8),
                        Text(
                          'Select Your Language',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Choose your preferred language',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

                // Language List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _languages.length,
                    itemBuilder: (context, index) {
                      final language = _languages[index];
                      final isSelected = language['name'] == _selectedLanguage;

                      return FadeInLeft(
                        delay: Duration(milliseconds: index * 50),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: isSelected ? 4 : 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: isSelected
                                ? BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 2,
                                  )
                                : BorderSide.none,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  language['flag']!,
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                            ),
                            title: Text(
                              language['name']!,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Theme.of(context).primaryColor : null,
                              ),
                            ),
                            subtitle: Text(
                              language['native']!,
                              style: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).primaryColor.withOpacity(0.7)
                                    : Colors.grey[600],
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).primaryColor,
                                    size: 28,
                                  )
                                : Icon(
                                    Icons.circle_outlined,
                                    color: Colors.grey[400],
                                    size: 28,
                                  ),
                            onTap: () => _saveLanguage(language['name']!),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Info Footer
                FadeInUp(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Full multi-language support coming soon!',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
