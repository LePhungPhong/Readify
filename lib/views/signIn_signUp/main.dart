import 'package:flutter/material.dart';
import 'package:readify/views/signIn_signUp/SplashScreen.dart';
import 'package:readify/views/signIn_signUp/Login_Signup.dart';
import 'package:readify/views/signIn_signUp/Register.dart';
import 'package:readify/views/signIn_signUp/Login.dart';

void main() {
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
