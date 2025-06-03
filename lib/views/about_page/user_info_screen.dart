import 'package:flutter/material.dart';
import 'package:readify/controllers/Phong/AuthService.dart';
import 'package:readify/controllers/local_book_controller.dart';
import 'package:readify/models/Phong/user_model.dart';
import 'package:readify/models/book_model.dart';
import 'package:readify/views/docsachs/detail_book.dart';
import 'package:readify/views/settings/settings_page.dart';

class UserInfoScreen extends StatelessWidget {
  final UserModel user;
  // final Color mainColor = const Color(0xFFB74F4F); // Remove this line

  const UserInfoScreen({super.key, required this.user});

  Future<UserModel?> _loadUserData() async {
    final authService = AuthService();
    final currentUser = await authService.getCurrentUser();
    return currentUser;
  }

  Future<List<Book>> _loadMyBooks() async {
    final localController = LocalBookController();
    return localController.getBooksByType("my_books");
  }

  Future<List<Book>> _loadFavoriteBooks() async {
    final localController = LocalBookController();
    return localController.getBooksByType("favorite_books");
  }

  Widget _buildBookSection(
    String title,
    Future<List<Book>> futureBooks,
    BuildContext context,
  ) {
    // Get the color scheme from the theme
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<Book>>(
      future: futureBooks,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "$title: Không có sách nào.",
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color:
                    colorScheme
                        .onSurfaceVariant, // Adjusted for better contrast
              ),
            ),
          );
        }

        final books = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title (${books.length})',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary, // Use primary color from theme
                shadows: const [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    BookDetailPage(bookId: book.id, user: user),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                if (book.coverUrl != null &&
                                    book.coverUrl!.isNotEmpty)
                                  Image.network(
                                    book.coverUrl!,
                                    width: 120,
                                    height: 160,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => Container(
                                          color:
                                              colorScheme
                                                  .surfaceVariant, // Using a theme color
                                          child: Icon(
                                            Icons.broken_image,
                                            color:
                                                colorScheme
                                                    .onSurface, // Using a theme color
                                          ),
                                        ),
                                  )
                                else
                                  Container(
                                    width: 120,
                                    height: 160,
                                    color:
                                        colorScheme
                                            .surfaceVariant, // Using a theme color
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color:
                                          colorScheme
                                              .onSurface, // Using a theme color
                                    ),
                                  ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 120,
                            child: Text(
                              book.title ?? 'Không có tiêu đề',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color:
                                    colorScheme
                                        .onSurface, // Using a theme color
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the color scheme from the theme
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor:
          colorScheme.background, // Use background color from theme
      appBar: AppBar(
        backgroundColor: colorScheme.primary, // Use primary color from theme
        title: Text(
          'Thông tin người dùng',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ), // Text color on primary
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: colorScheme.onPrimary,
            ), // Icon color on primary
            tooltip: 'Cài đặt',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<UserModel?>(
        future: _loadUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          final user = snapshot.data;
          if (user == null) {
            return Center(
              child: Text(
                'Không thể tải thông tin người dùng.',
                style: TextStyle(
                  color: colorScheme.error,
                ), // Use error color for issues
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: colorScheme.primary, // Use primary color
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.6),
                        offset: const Offset(0, 4),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Readify',
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary.withOpacity(
                          0.15,
                        ), // Text color on primary with opacity
                        letterSpacing: 8,
                        shadows: const [
                          Shadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // User Info Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  transform: Matrix4.translationValues(0, -40, 0),
                  decoration: BoxDecoration(
                    color: colorScheme.surface, // Use surface color
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(
                          0.12,
                        ), // Use shadow color from theme
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withOpacity(
                                0.26,
                              ), // Use shadow color from theme
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              colorScheme.surface, // Use surface color
                          backgroundImage:
                              user.avatarUrl != null &&
                                      user.avatarUrl!.isNotEmpty
                                  ? NetworkImage(user.avatarUrl!)
                                  : const AssetImage(
                                        'assets/images/Untitled.png',
                                      )
                                      as ImageProvider,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary, // Use primary color
                                shadows: const [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  size: 20,
                                  color:
                                      colorScheme
                                          .onSurfaceVariant, // Use onSurfaceVariant for icons
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    user.email,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          colorScheme
                                              .onSurfaceVariant, // Use onSurfaceVariant for secondary text
                                      fontStyle: FontStyle.italic,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Book Sections
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBookSection(
                        "Lịch sử đọc sách",
                        _loadMyBooks(),
                        context,
                      ),
                      const SizedBox(height: 30),
                      _buildBookSection(
                        "Sách được yêu thích",
                        _loadFavoriteBooks(),
                        context,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
