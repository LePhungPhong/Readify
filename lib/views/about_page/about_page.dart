import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

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
    final textTheme = Theme.of(context).textTheme; // Access TextTheme here

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
                      // ONLY MODIFYING FONT SIZE
                      style: textTheme.headlineSmall?.copyWith(
                        // Original fontSize: 20
                        color: primaryColor,
                        shadows: const [
                          Shadow(
                            color: Colors.black12,
                            offset: Offset(1, 1),
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
                        // ONLY MODIFYING FONT SIZE
                        style: textTheme.titleMedium?.copyWith(
                          // Original fontSize: was around 16-17 for similar content
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
    final textTheme = Theme.of(context).textTheme; // Access TextTheme here

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Giới thiệu ứng dụng',
          // ONLY MODIFYING FONT SIZE
          style: textTheme.titleLarge?.copyWith(
            color: Colors.white,
          ), // Original fontSize: 20
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
                        // ONLY MODIFYING FONT SIZE
                        style: textTheme.displayMedium?.copyWith(
                          // Original fontSize: 50
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              color: Colors.black38,
                              offset: Offset(2, 2),
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
            isHighlighted: true,
          ),
          _buildSection(
            icon: Icons.lightbulb,
            title: 'Công nghệ sử dụng',
            content:
                'Ứng dụng được phát triển với Flutter, sử dụng Firebase cho backend và quản lý dữ liệu, đảm bảo hiệu suất cao và trải nghiệm mượt mà.',
          ),
          _buildSection(
            icon: Icons.groups,
            title: 'Đội ngũ phát triển',
            contentWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTeamMember('PD: Nguyễn Hữu Phong'),
                _buildTeamMember('TL: Lê Thị Diễm Thúy'),
                _buildTeamMember('TV: Nguyễn Duy Tân'),
                _buildTeamMember('TV: Hồ Trọng Nghĩa'),
              ],
            ),
          ),
          _buildSection(
            icon: Icons.contact_mail,
            title: 'Liên hệ chúng tôi',
            contentWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ContactItem(
                  icon: Icons.email,
                  text: 'readify.app@gmail.com',
                  accentColor: accentColor,
                ),
                _ContactItem(
                  icon: Icons.phone,
                  text: '+84 123 456 789',
                  accentColor: accentColor,
                ),
                _ContactItem(
                  icon: Icons.location_on,
                  text: 'Đại học Sài Gòn, TP.HCM, Việt Nam',
                  accentColor: accentColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(String text) {
    final textTheme = Theme.of(context).textTheme; // Access TextTheme here
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            text.substring(0, 2),
            // ONLY MODIFYING FONT SIZE
            style: textTheme.titleMedium?.copyWith(
              color: const Color(0xFF6D4C41),
            ), // Original fontSize: 18
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text.substring(2),
              // ONLY MODIFYING FONT SIZE
              style: textTheme.titleMedium?.copyWith(
                color: Colors.black87,
              ), // Original fontSize: 18
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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme; // Access TextTheme here
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: accentColor, size: 24),
      title: Text(text, style: textTheme.titleMedium), // Original fontSize: 17
      dense: true,
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
