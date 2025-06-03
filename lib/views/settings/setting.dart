import 'package:flutter/material.dart';
import 'package:readify/models/Phong/user_model.dart';
import 'package:readify/views/danhmuc/book_list_view.dart';
import 'package:readify/views/signIn_signUp/Login_Signup.dart';
import 'settings_page.dart'; // import SettingsPage
import 'package:readify/views/about_page/user_info_screen.dart';
import 'package:readify/main.dart'; // Import main.dart to access notifiers

class HomePage extends StatelessWidget {
  final UserModel user;
  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final ColorScheme colorScheme =
        Theme.of(context).colorScheme; // Get colorScheme
    return AppBar(
      title: const Text('Readify'),
      centerTitle: true,
      backgroundColor: colorScheme.primary, // Use primary color
      foregroundColor: colorScheme.onPrimary, // Use onPrimary color
      actions: [
        IconButton(
          icon: Icon(
            Icons.account_circle,
            color: colorScheme.onPrimary,
          ), // Use onPrimary color
          tooltip: 'Thông tin người dùng',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserInfoScreen(user: user),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(
            Icons.settings,
            color: colorScheme.onPrimary,
          ), // Use onPrimary color
          tooltip: 'Cài đặt',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
        ),
      ],
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
          _buildThemeSwitchTile(context), // Pass context
          _buildLanguageDropdownTile(context), // Pass context
          _buildFontSizeDropdownTile(context), // Pass context
          _buildLogoutTile(context),
        ],
      ),
    );
  }

  DrawerHeader _buildDrawerHeader(BuildContext context) {
    final ColorScheme colorScheme =
        Theme.of(context).colorScheme; // Get colorScheme
    return DrawerHeader(
      decoration: BoxDecoration(
        color: colorScheme.primary,
      ), // Use primary color
      child: Text(
        'Menu',
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 24,
        ), // Use onPrimary color
      ),
    );
  }

  ListTile _buildThemeSwitchTile(BuildContext context) {
    // Accept context
    final ColorScheme colorScheme =
        Theme.of(context).colorScheme; // Get colorScheme
    return ListTile(
      leading: Icon(
        Icons.brightness_6,
        color: colorScheme.onSurface,
      ), // Use onSurface for icons
      title: Text(
        'Chế độ sáng/tối',
        style: TextStyle(color: colorScheme.onSurface),
      ), // Use onSurface for text
      trailing: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, currentTheme, _) {
          return Switch(
            value: currentTheme == ThemeMode.dark,
            activeColor:
                colorScheme.primary, // Use primary color for active switch
            onChanged: (value) {
              themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
            },
          );
        },
      ),
    );
  }

  ListTile _buildLanguageDropdownTile(BuildContext context) {
    // Accept context
    final ColorScheme colorScheme =
        Theme.of(context).colorScheme; // Get colorScheme
    return ListTile(
      leading: Icon(
        Icons.language,
        color: colorScheme.onSurface,
      ), // Use onSurface for icons
      title: Text(
        'Ngôn ngữ',
        style: TextStyle(color: colorScheme.onSurface),
      ), // Use onSurface for text
      trailing: ValueListenableBuilder<String>(
        valueListenable: languageNotifier,
        builder: (context, currentLanguage, _) {
          return DropdownButton<String>(
            value: currentLanguage,
            items: [
              DropdownMenuItem(
                value: 'Tiếng Việt',
                child: Text(
                  'Tiếng Việt',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ), // Use onSurface
              DropdownMenuItem(
                value: 'English',
                child: Text(
                  'English',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ), // Use onSurface
            ],
            onChanged: (value) {
              if (value != null) languageNotifier.value = value;
            },
          );
        },
      ),
    );
  }

  ListTile _buildFontSizeDropdownTile(BuildContext context) {
    // Accept context
    final ColorScheme colorScheme =
        Theme.of(context).colorScheme; // Get colorScheme
    return ListTile(
      leading: Icon(
        Icons.format_size,
        color: colorScheme.onSurface,
      ), // Use onSurface for icons
      title: Text(
        'Cỡ chữ',
        style: TextStyle(color: colorScheme.onSurface),
      ), // Use onSurface for text
      subtitle: ValueListenableBuilder<double>(
        valueListenable: fontSizeNotifier,
        builder: (context, currentFontSize, _) {
          return DropdownButton<double>(
            value: currentFontSize,
            isExpanded: true,
            items: [
              DropdownMenuItem(
                value: 12.0,
                child: Text(
                  '12',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ), // Use onSurface
              DropdownMenuItem(
                value: 14.0,
                child: Text(
                  '14',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ), // Use onSurface
              DropdownMenuItem(
                value: 16.0,
                child: Text(
                  '16',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ), // Use onSurface
              DropdownMenuItem(
                value: 18.0,
                child: Text(
                  '18',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ), // Use onSurface
              DropdownMenuItem(
                value: 20.0,
                child: Text(
                  '20',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ), // Use onSurface
              DropdownMenuItem(
                value: 24.0,
                child: Text(
                  '24',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ), // Use onSurface
              DropdownMenuItem(
                value: 28.0,
                child: Text(
                  '28',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ), // Use onSurface
            ],
            onChanged: (value) {
              if (value != null) fontSizeNotifier.value = value;
            },
          );
        },
      ),
    );
  }

  ListTile _buildLogoutTile(BuildContext context) {
    final ColorScheme colorScheme =
        Theme.of(context).colorScheme; // Get colorScheme
    return ListTile(
      leading: Icon(
        Icons.logout,
        color: colorScheme.error,
      ), // Use error color for logout
      title: Text(
        'Đăng xuất',
        style: TextStyle(color: colorScheme.error),
      ), // Use error color for logout
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginSignup()),
        );
      },
    );
  }

  Widget _buildBody() {
    return Center(
      child: ValueListenableBuilder<double>(
        valueListenable: fontSizeNotifier,
        builder: (context, currentFontSize, _) {
          return BookListView(user: user);
        },
      ),
    );
  }
}
