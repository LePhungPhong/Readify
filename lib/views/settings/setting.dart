import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:readify/models/Phong/user_model.dart';
import 'package:readify/views/danhmuc/book_list_view.dart';
import 'settings_page.dart'; // import SettingsPage
import 'package:readify/views/about_page/user_info_screen.dart';
import 'package:readify/main.dart'; // Import main.dart to access notifiers

class SettingPage extends StatelessWidget {
  final UserModel user;
  const SettingPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, _) {
        return ValueListenableBuilder<double>(
          valueListenable: fontSizeNotifier,
          builder: (context, currentFontSize, __) {
            return ValueListenableBuilder<String>(
              valueListenable: languageNotifier,
              builder: (context, currentLanguage, ___) {
                final locale =
                    currentLanguage == 'English'
                        ? const Locale('en')
                        : const Locale('vi');

                // Thêm kiểm tra an toàn cho fontSizeFactor tại đây cũng
                final double safeFontSizeFactor =
                    currentFontSize > 0 ? currentFontSize / 16.0 : 1.0;

                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Readify',
                  locale: locale,
                  supportedLocales: const [Locale('vi'), Locale('en')],
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  themeMode: currentTheme,
                  theme: ThemeData(
                    useMaterial3: true,
                    colorSchemeSeed: Colors.red,
                    brightness: Brightness.light,
                    textTheme: ThemeData.light().textTheme.apply(
                      fontSizeFactor:
                          safeFontSizeFactor, // Sử dụng biến an toàn
                    ),
                  ),
                  darkTheme: ThemeData.from(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: Colors.red,
                      brightness: Brightness.dark,
                    ),
                    textTheme: ThemeData.dark().textTheme.apply(
                      fontSizeFactor:
                          safeFontSizeFactor, // Sử dụng biến an toàn
                    ),
                  ),
                  home: HomePage(user: user),
                );
              },
            );
          },
        );
      },
    );
  }
}

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
    return AppBar(
      title: const Text('Readify'),
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle),
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
          icon: const Icon(Icons.settings),
          tooltip: 'Cài đặt',
          onPressed: () {
            Navigator.pushReplacement(
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
          _buildThemeSwitchTile(),
          _buildLanguageDropdownTile(),
          _buildFontSizeDropdownTile(),
          _buildLogoutTile(context),
        ],
      ),
    );
  }

  DrawerHeader _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
      child: const Text(
        'Menu',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  ListTile _buildThemeSwitchTile() {
    return ListTile(
      leading: const Icon(Icons.brightness_6),
      title: const Text('Chế độ sáng/tối'),
      trailing: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, currentTheme, _) {
          return Switch(
            value: currentTheme == ThemeMode.dark,
            onChanged: (value) {
              themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
            },
          );
        },
      ),
    );
  }

  ListTile _buildLanguageDropdownTile() {
    return ListTile(
      leading: const Icon(Icons.language),
      title: const Text('Ngôn ngữ'),
      trailing: ValueListenableBuilder<String>(
        valueListenable: languageNotifier,
        builder: (context, currentLanguage, _) {
          return DropdownButton<String>(
            value: currentLanguage,
            items: const [
              DropdownMenuItem(value: 'Tiếng Việt', child: Text('Tiếng Việt')),
              DropdownMenuItem(value: 'English', child: Text('English')),
            ],
            onChanged: (value) {
              if (value != null) languageNotifier.value = value;
            },
          );
        },
      ),
    );
  }

  ListTile _buildFontSizeDropdownTile() {
    return ListTile(
      leading: const Icon(Icons.format_size),
      title: const Text('Cỡ chữ'),
      subtitle: ValueListenableBuilder<double>(
        valueListenable: fontSizeNotifier,
        builder: (context, currentFontSize, _) {
          return DropdownButton<double>(
            value: currentFontSize,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 12.0, child: Text('12')),
              DropdownMenuItem(value: 14.0, child: Text('14')),
              DropdownMenuItem(value: 16.0, child: Text('16')),
              DropdownMenuItem(value: 18.0, child: Text('18')),
              DropdownMenuItem(value: 20.0, child: Text('20')),
              DropdownMenuItem(value: 24.0, child: Text('24')),
              DropdownMenuItem(value: 28.0, child: Text('28')),
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
    return ListTile(
      leading: const Icon(Icons.logout),
      title: const Text('Đăng xuất'),
      onTap: () {
        Navigator.pop(context);
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
