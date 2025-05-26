import 'package:flutter/material.dart';
import 'package:readify/views/signIn_signUp/SplashScreen.dart';
import 'package:readify/views/signIn_signUp/Login_Signup.dart';
import 'package:readify/views/signIn_signUp/Register.dart';
import 'package:readify/views/signIn_signUp/Login.dart';
import 'package:readify/db/database_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Readify',
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/Login_Signup': (context) => LoginSignup(),
        '/Register': (context) => Register(),
        '/Login': (context) => Login(),
      },
    );
  }
}
