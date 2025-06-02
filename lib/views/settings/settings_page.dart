import 'package:flutter/material.dart';
import 'package:readify/views/settings/main.dart';
import 'package:readify/views/signIn_signUp/Login_Signup.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const Color mainColor = Color(0xFFB74F4F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Cài Đặt'),
        centerTitle: true,
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionCard(
            context,
            icon: Icons.brightness_6,
            title: 'Chế độ sáng/tối',
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, currentTheme, _) {
                return Switch(
                  value: currentTheme == ThemeMode.dark,
                  activeColor: mainColor,
                  onChanged: (value) {
                    themeNotifier.value =
                        value ? ThemeMode.dark : ThemeMode.light;
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            context,
            icon: Icons.language,
            title: 'Ngôn ngữ',
            child: ValueListenableBuilder<String>(
              valueListenable: languageNotifier,
              builder: (context, currentLanguage, _) {
                return DropdownButton<String>(
                  value: currentLanguage,
                  onChanged: (value) {
                    if (value != null) languageNotifier.value = value;
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 'Tiếng Việt',
                      child: Text('Tiếng Việt'),
                    ),
                    DropdownMenuItem(value: 'English', child: Text('English')),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            context,
            icon: Icons.format_size,
            title: 'Cỡ chữ',
            child: ValueListenableBuilder<double>(
              valueListenable: fontSizeNotifier,
              builder: (context, currentFontSize, _) {
                return Column(
                  children: [
                    Slider(
                      value: currentFontSize,
                      min: 12,
                      max: 28,
                      divisions: 8,
                      label: currentFontSize.toStringAsFixed(0),
                      activeColor: mainColor,
                      onChanged: (value) {
                        fontSizeNotifier.value = value;
                      },
                    ),
                    Text(
                      'Cỡ hiện tại: ${currentFontSize.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 14, color: mainColor),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Đăng Xuất'),
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              shadowColor: Colors.redAccent.withOpacity(0.5),
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginSignup()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: mainColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
