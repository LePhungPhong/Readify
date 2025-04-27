import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/Login_Signup');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Color.fromARGB(255, 189, 90, 90),
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 200),
                child: Text(
                  'Readify',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 90,
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            Image.asset('assets/images/Untitled.png'),
          ],
        ),
      ),
    );
  }
}
