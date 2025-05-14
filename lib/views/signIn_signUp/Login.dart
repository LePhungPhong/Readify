import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readify/controllers/Phong/AuthService.dart';
import 'package:readify/views/danhmuc/home_view.dart';
//import 'package:readify/models/Phong/user_model.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscureText = true;
  bool _isLoading = false;

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ email và mật khẩu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = await _authService.login(email, password);

    setState(() => _isLoading = false);

    if (user != null) {
      // Đăng nhập thành công
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Xin chào, ${user.name}!')));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeView()),
      );
    } else {
      // Sai thông tin đăng nhập
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email hoặc mật khẩu không đúng')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 189, 90, 90),
        title: Text(
          'Readify',
          style: GoogleFonts.roboto(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đăng nhập tài khoản',
              style: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 189, 90, 90),
              ),
            ),
            const SizedBox(height: 30),

            // Email
            Text(
              'Email',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Nhập email",
                prefixIcon: const Icon(Icons.email),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 189, 90, 90),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Password
            Text(
              'Password',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                hintText: "Nhập mật khẩu",
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 189, 90, 90),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Forgot password action
                },
                child: Text(
                  "Quên mật khẩu?",
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Login Button
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color.fromARGB(255, 189, 90, 90),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            "Login",
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
