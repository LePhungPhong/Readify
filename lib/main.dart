import 'package:flutter/material.dart';
import 'package:readify/views/signIn_signUp/SplashScreen.dart';
import 'package:readify/views/signIn_signUp/Login_Signup.dart';
import 'package:readify/views/signIn_signUp/Register.dart';
import 'package:readify/views/signIn_signUp/Login.dart';
import 'package:readify/db/database_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:readify/views/settings/setting.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<String> languageNotifier = ValueNotifier('Tiếng Việt');
final ValueNotifier<double> fontSizeNotifier = ValueNotifier(16.0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, _) {
        return ValueListenableBuilder<String>(
          valueListenable: languageNotifier,
          builder: (context, currentLanguage, _) {
            final locale =
                currentLanguage == 'English'
                    ? const Locale('en')
                    : const Locale('vi');

            return ValueListenableBuilder<double>(
              valueListenable: fontSizeNotifier,
              builder: (context, currentFontSize, _) {
                // Định nghĩa TextTheme có fontSize rõ ràng
                final TextTheme customTextTheme = TextTheme(
                  bodyLarge: TextStyle(fontSize: currentFontSize),
                  bodyMedium: TextStyle(fontSize: currentFontSize),
                  bodySmall: TextStyle(fontSize: currentFontSize - 2),
                  titleLarge: TextStyle(fontSize: currentFontSize + 2),
                  titleMedium: TextStyle(fontSize: currentFontSize),
                  titleSmall: TextStyle(fontSize: currentFontSize - 2),
                  labelLarge: TextStyle(fontSize: currentFontSize - 2),
                  labelMedium: TextStyle(fontSize: currentFontSize - 3),
                );

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
                    textTheme: customTextTheme,
                  ),
                  darkTheme: ThemeData(
                    useMaterial3: true,
                    colorSchemeSeed: Colors.red,
                    brightness: Brightness.dark,
                    textTheme: customTextTheme,
                  ),
                  initialRoute: '/',
                  routes: {
                    '/': (context) => const SplashScreen(),
                    '/Login_Signup': (context) => const LoginSignup(),
                    '/Register': (context) => const Register(),
                    '/Login': (context) => const Login(),
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
