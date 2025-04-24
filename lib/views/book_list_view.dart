import 'package:flutter/material.dart';
import 'package:readify/views/book_by_category.dart';
import '../controllers/book_controller.dart';
import '../controllers/local_book_controller.dart';
import '../models/book_model.dart';

class BookListView extends StatefulWidget {
  @override
  _BookListViewState createState() => _BookListViewState();
}

class _BookListViewState extends State<BookListView> {
  final BookController controller = BookController();
  final LocalBookController localController = LocalBookController();

  late Future<List<Book>> recentBooks;
  late Future<List<Book>> myBooks;
  late Future<List<Book>> favoriteBooks;

  @override
  void initState() {
    super.initState();
    recentBooks = controller.getBooks();
    myBooks = localController.getMyBooks();
    favoriteBooks = localController.getFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recently Added Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFBD5A5A),
                  const Color(0xFFBD5A5A).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Recently Added",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
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
                  height: 240,
                  child: FutureBuilder<List<Book>>(
                    future: recentBooks,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            "Không có sách mới.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }
                      final books = snapshot.data!;
                      return PageView.builder(
                        controller: PageController(viewportFraction: 0.55),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: GestureDetector(
                              onTap: () {
                                // Xử lý khi nhấn vào sách
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Stack(
                                          children: [
                                            Image.network(
                                              book.coverUrl ?? '',
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              errorBuilder:
                                                  (_, __, ___) => Container(
                                                    color: Colors.grey[300],
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                      size: 48,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                            ),
                                            Positioned.fill(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        4,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      book.title ?? 'Không có tiêu đề',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        fontSize: 15,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black26,
                                            offset: Offset(1, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // My Books Section
          _buildBookSection("Sách của tôi", myBooks),

          const SizedBox(height: 30),

          // Favorites Section
          _buildBookSection("Sách được yêu thích", favoriteBooks),

          const SizedBox(height: 30),

          // Categories Section
          const Text(
            "Thể loại",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFBD5A5A),
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildCategories(context),
        ],
      ),
    );
  }

  Widget _buildBookSection(String title, Future<List<Book>> futureBooks) {
    return FutureBuilder<List<Book>>(
      future: futureBooks,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final books = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title (${books.length})',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFBD5A5A),
                shadows: [
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
                        // Xử lý khi nhấn vào sách
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                children: [
                                  Image.network(
                                    book.coverUrl ?? '',
                                    width: 120,
                                    height: 160,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => Container(
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                          ),
                                        ),
                                  ),
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
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
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildCategories(BuildContext context) {
    final categoryMapping = {
      'Imagine': 'fantasy',
      'Fiction': 'fiction',
      'Criminal': 'crime',
      "Children's": 'children',
      'Horrified': 'horror',
      'Emotional': 'drama',
    };

    final categories = categoryMapping.keys.toList();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          categories.map((category) {
            final topic = categoryMapping[category];
            final imgPath = 'assets/categories/$topic.jpg';
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BooksByCategoryPage(topic: topic!),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: (MediaQuery.of(context).size.width - 44) / 2,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: AssetImage(imgPath),
                    fit: BoxFit.cover,
                    onError: (_, __) => print('Lỗi tải ảnh: $imgPath'),
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5),
                      BlendMode.darken,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
