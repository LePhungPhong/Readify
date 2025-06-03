import 'package:flutter/material.dart';
import 'package:readify/main.dart';
import 'package:readify/views/signIn_signUp/Login_Signup.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // static const Color mainColor = Color(0xFFB74F4F); // Remove this line

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background, // Use background color
      appBar: AppBar(
        title: Text(
          'Cài Đặt',
          style: TextStyle(
            color: colorScheme.onPrimary,
          ), // Text color on primary
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary, // Use primary color
        foregroundColor: colorScheme.onPrimary, // Icon/text color on primary
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionCard(
            icon: Icons.brightness_6,
            title: 'Chế độ sáng/tối',
            context: context, // Pass context to _buildSectionCard
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, currentTheme, _) {
                return Switch(
                  value: currentTheme == ThemeMode.dark,
                  activeColor:
                      colorScheme
                          .primary, // Use primary color for active switch
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
            icon: Icons.language,
            title: 'Ngôn ngữ',
            context: context, // Pass context
            child: ValueListenableBuilder<String>(
              valueListenable: languageNotifier,
              builder: (context, currentLanguage, _) {
                return DropdownButton<String>(
                  value: currentLanguage,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: colorScheme.onSurface,
                  ), // Use onSurface for dropdown icon
                  onChanged: (value) {
                    if (value != null) languageNotifier.value = value;
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'Tiếng Việt',
                      child: Text(
                        'Tiếng Việt',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'English',
                      child: Text(
                        'English',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            icon: Icons.format_size,
            title: 'Cỡ chữ',
            context: context, // Pass context
            child: ValueListenableBuilder<double>(
              valueListenable: fontSizeNotifier,
              builder: (context, currentFontSize, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Slider(
                      value: currentFontSize,
                      min: 12,
                      max: 28,
                      divisions: 8,
                      label: currentFontSize.toStringAsFixed(0),
                      activeColor:
                          colorScheme
                              .primary, // Use primary color for active slider
                      onChanged: (value) {
                        fontSizeNotifier.value = value;
                      },
                    ),
                    Text(
                      'Cỡ hiện tại: ${currentFontSize.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.primary,
                      ), // Use primary for text color
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: Icon(
              Icons.logout,
              color: colorScheme.onPrimary,
            ), // Icon color on primary
            label: Text(
              'Đăng Xuất',
              style: TextStyle(color: colorScheme.onPrimary),
            ), // Text color on primary
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  colorScheme.error, // Use error color for logout button
              foregroundColor: colorScheme.onError, // Text/icon color on error
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              shadowColor: colorScheme.shadow.withOpacity(
                0.5,
              ), // Use shadow color
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginSignup()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
    required BuildContext context, // Add context here
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surface, // Use surface color for the card background
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: colorScheme.primary,
            ), // Use primary color for card icons
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface, // Text color on surface
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
