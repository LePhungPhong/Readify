import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readify/database/db_helper.dart'; // Cập nhật import đúng nếu cần

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _avatarUrlController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final name = _usernameController.text.trim();
      final avatarUrl = _avatarUrlController.text.trim();

      final error = await AppDatabase().registerUserSecure(
        email: email,
        password: password,
        name: name,
        avatarUrl:
            avatarUrl.isEmpty
                ? 'https://example.com/default_avatar.png'
                : avatarUrl,
      );

      if (error == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đăng ký thành công!')));

        // Log tất cả tài khoản sau khi đăng ký thành công
        await _logAllUsers();

        Navigator.pushReplacementNamed(context, '/Login');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  // Hàm log tất cả tài khoản ra console
  Future<void> _logAllUsers() async {
    final users =
        await AppDatabase().getAllUsers(); // Lấy danh sách người dùng từ DB

    // In từng tài khoản ra console
    for (var user in users) {
      print(
        'User: ${user.name}, Email: ${user.email}, Avatar URL: ${user.avatarUrl}',
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 189, 90, 90),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Readify',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tạo tài khoản',
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 189, 90, 90),
                ),
              ),
              const SizedBox(height: 30),

              // Username
              _buildLabel("Tên người dùng"),
              _buildTextField(
                _usernameController,
                Icons.person,
                "Nhập tên người dùng",
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên người dùng';
                  }
                  return null;
                },
              ),

              // Email
              _buildLabel("Email"),
              _buildTextField(_emailController, Icons.email, "Nhập email", (
                value,
              ) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập email';
                }
                if (!value.contains('@')) {
                  return 'Email không hợp lệ';
                }
                return null;
              }),

              // Password
              _buildLabel("Mật khẩu"),
              _buildPasswordField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                toggle:
                    () => setState(() => _obscurePassword = !_obscurePassword),
                hintText: "Nhập mật khẩu",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  if (value.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự';
                  }
                  return null;
                },
              ),

              // Confirm Password
              _buildLabel("Xác nhận mật khẩu"),
              _buildPasswordField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                toggle:
                    () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                hintText: "Nhập lại mật khẩu",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập lại mật khẩu';
                  }
                  if (value != _passwordController.text) {
                    return 'Mật khẩu không khớp';
                  }
                  return null;
                },
              ),

              // Avatar URL (tùy chọn)
              _buildLabel("Avatar URL (tùy chọn)"),
              _buildTextField(
                _avatarUrlController,
                Icons.image,
                "Nhập URL hình đại diện (nếu có)",
                (value) {
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // Register Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color.fromARGB(255, 189, 90, 90),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Đăng ký',
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
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color.fromARGB(255, 189, 90, 90),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    IconData icon,
    String hint,
    String? Function(String?)? validator,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromARGB(255, 189, 90, 90)),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggle,
    required String hintText,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromARGB(255, 189, 90, 90)),
        ),
      ),
    );
  }
}
