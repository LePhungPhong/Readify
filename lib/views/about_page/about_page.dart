import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
    with SingleTickerProviderStateMixin {
  final Color primaryColor = const Color(0xFF6D4C41); // Rich brown
  final Color accentColor = const Color(0xFFFFA726); // Vibrant orange

  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    String? content,
    Widget? contentWidget,
    bool isHighlighted = false, // Flag to highlight specific sections
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        color: Colors.white.withOpacity(0.95),
        child: Container(
          decoration:
              isHighlighted
                  ? BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [accentColor.withOpacity(0.1), Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  )
                  : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Icon(icon, color: accentColor, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                        shadows: [
                          Shadow(
                            color: Colors.black12,
                            offset: const Offset(1, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1.5, color: Colors.grey),
                FadeTransition(
                  opacity: _fadeInAnimation,
                  child:
                      contentWidget ??
                      Text(
                        content ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.6,
                          color: Colors.black87,
                          fontStyle:
                              isHighlighted
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                        ),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Giới thiệu ứng dụng',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          ClipPath(
            clipper: BottomCurveClipper(),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, accentColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeInAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Readify',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black38,
                              offset: const Offset(2, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(80),
                          child: Image.asset(
                            'assets/images/reading.png',
                            width: 160,
                            height: 160,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.broken_image,
                                size: 160,
                                color: Colors.white70,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          _buildSection(
            icon: Icons.flag,
            title: 'Mục tiêu ứng dụng',
            content:
                'Readify mang đến trải nghiệm đọc sách hiện đại, dễ sử dụng và thân thiện, giúp bạn lưu trữ, quản lý và khám phá hàng ngàn cuốn sách ngay trên điện thoại.',
            isHighlighted: true, // Highlight this section
          ),

          _buildSection(
            icon: Icons.person,
            title: 'Đối tượng người dùng',
            content:
                'Phù hợp với mọi lứa tuổi yêu sách, từ học sinh, sinh viên đến nhân viên văn phòng, người yêu văn học, kỹ năng, tiếng Anh và nhiều thể loại khác.',
          ),

          _buildSection(
            icon: Icons.star,
            title: 'Tính năng nổi bật',
            contentWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _FeatureItem(text: '📚 Giao diện đọc tối ưu, thân thiện.'),
                _FeatureItem(text: '🔍 Tìm kiếm và phân loại sách thông minh.'),
                _FeatureItem(text: '❤️ Lưu sách yêu thích, theo dõi đọc.'),
                _FeatureItem(text: '📈 Thống kê đọc theo thời gian.'),
                _FeatureItem(text: '📤 Chia sẻ sách dễ dàng.'),
              ],
            ),
          ),

          _buildSection(
            icon: Icons.contact_mail,
            title: 'Thông tin liên hệ',
            contentWidget: Column(
              children: const [
                _ContactItem(
                  icon: Icons.phone,
                  text: 'Số điện thoại: 1900 545482',
                  accentColor: Color(0xFFFFA726),
                ),
                _ContactItem(
                  icon: Icons.email,
                  text: 'Email: support@readify.app',
                  accentColor: Color(0xFFFFA726),
                ),
                _ContactItem(
                  icon: Icons.info,
                  text: 'Phiên bản: 1.0.0',
                  accentColor: Color(0xFFFFA726),
                ),
                _ContactItem(
                  icon: Icons.privacy_tip,
                  text: 'Chính sách bảo mật',
                  accentColor: Color(0xFFFFA726),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;

  const _FeatureItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            text.substring(0, 2),
            style: const TextStyle(fontSize: 18, color: Color(0xFF6D4C41)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text.substring(2),
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color accentColor;

  const _ContactItem({
    required this.icon,
    required this.text,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: accentColor, size: 24),
      title: Text(text, style: const TextStyle(fontSize: 17)),
      dense: true,
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
