import 'package:flutter/material.dart';
import 'package:readify/database/db_helper.dart';
import 'package:readify/models/book_model.dart';

class UserInfoScreen extends StatelessWidget {
  final Color mainColor = const Color(0xFFB74F4F);
  final int? userId; // Thay đổi thành nullable int với giá trị mặc định null

  const UserInfoScreen({this.userId = null}); // Giá trị mặc định là null

  Future<User?> _loadUserData() async {
    if (userId == null) return null; // Trả về null nếu không có userId
    final db = AppDatabase();
    final dbClient = await db.db;

    final result = await dbClient.query(
      'Users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _loadReadingHistory() async {
    final db = AppDatabase();
    final dbClient = await db.db;

    final result = await dbClient.rawQuery('''
      SELECT Books.title, ReadingStatus.current_page, ReadingStatus.is_bookmarked
      FROM ReadingStatus
      JOIN Books ON ReadingStatus.book_id = Books.id
    ''');

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thông tin người dùng',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<User?>(
        future: _loadUserData(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = userSnapshot.data;

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _loadReadingHistory(),
            builder: (context, historySnapshot) {
              if (historySnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final readingHistory = historySnapshot.data ?? [];

              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  ClipPath(
                    clipper: BottomCurveClipper(),
                    child: Container(
                      height: 350,
                      color: mainColor,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Readify',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 20),
                            CircleAvatar(
                              radius: 60,
                              backgroundImage:
                                  user != null &&
                                          user.avatarUrl != null &&
                                          user.avatarUrl!.isNotEmpty
                                      ? NetworkImage(user.avatarUrl!)
                                          as ImageProvider
                                      : const AssetImage(
                                        'assets/images/napoleon.png',
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Thông tin cá nhân',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            shadows: [
                              Shadow(
                                color: Color(0xFFB74F4F),
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFFFD166)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFB74F4F),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InfoRow(
                                label: 'Tên',
                                value: user?.name ?? 'Không có thông tin',
                              ),
                              const SizedBox(height: 16),
                              InfoRow(
                                label: 'Email',
                                value: user?.email ?? 'Không có thông tin',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        const Text(
                          'Lịch sử đọc sách',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            shadows: [
                              Shadow(
                                color: Color(0xFFB74F4F),
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        ...readingHistory.map((entry) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFFFFF), Color(0xFFFFE0E0)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFFB74F4F),
                                  child: const Icon(
                                    Icons.book,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry['title'],
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Trang hiện tại: ${entry['current_page']}${entry['is_bookmarked'] == 1 ? ' (Đã đánh dấu)' : ''}',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 48),
                        const Text(
                          'Cảm ơn bạn đã sử dụng Readify!',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            height: 1.8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              height: 1.8,
            ),
          ),
        ),
      ],
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 100);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 60,
      size.width,
      size.height - 100,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
