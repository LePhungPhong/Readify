import 'package:flutter/material.dart';
import 'package:readify/models/Phong/user_model.dart';
import 'package:readify/views/danhmuc/book_by_category.dart';
import '../../controllers/book_controller.dart';
import '../../controllers/local_book_controller.dart';
import '../../models/book_model.dart';
import '../../views/docsachs/detail_book.dart';

class BookListView extends StatefulWidget {
  final UserModel user;
  const BookListView({super.key, required this.user});

  @override
  // ignore: library_private_types_in_public_api
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
    myBooks = localController.getBooksByType("my_books");
    favoriteBooks = localController.getBooksByType("favorite_books");
  }

  void reloadData() {
    setState(() {
      myBooks = localController.getBooksByType("my_books");
      favoriteBooks = localController.getBooksByType("favorite_books");
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme =
        Theme.of(context).colorScheme; // Lấy ColorScheme từ theme

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
                  colorScheme.primary, // Sử dụng primary color
                  colorScheme.primary.withOpacity(
                    0.8,
                  ), // Sử dụng primary color với opacity
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(
                    0.2,
                  ), // Sử dụng shadow color
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sách đề xuất",
                  style:
                      Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            colorScheme
                                .onPrimary, // Text color trên primary background
                        shadows: const [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ) ??
                      TextStyle(
                        // Fallback style
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color:
                            colorScheme
                                .onPrimary, // Text color trên primary background
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
                  height: 240,
                  child: FutureBuilder<List<Book>>(
                    future: recentBooks,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                          ),
                        ); // Sử dụng primary color
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            "Không có sách mới.",
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onPrimary.withOpacity(
                                    0.7,
                                  ), // Sử dụng onPrimary color với opacity
                                ) ??
                                TextStyle(
                                  // Fallback style
                                  color: colorScheme.onPrimary.withOpacity(
                                    0.7,
                                  ), // Sử dụng onPrimary color với opacity
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => BookDetailPage(
                                          bookId: book.id,
                                          user: widget.user,
                                        ),
                                  ),
                                ).then((_) => {reloadData()});
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
                                            if (book.coverUrl != null &&
                                                book.coverUrl!.isNotEmpty)
                                              Image.network(
                                                book.coverUrl!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                errorBuilder:
                                                    (_, __, ___) => Container(
                                                      color:
                                                          colorScheme
                                                              .surfaceVariant, // Sử dụng surfaceVariant
                                                      child: Icon(
                                                        Icons.broken_image,
                                                        size: 48,
                                                        color:
                                                            colorScheme
                                                                .onSurfaceVariant, // Sử dụng onSurfaceVariant
                                                      ),
                                                    ),
                                              )
                                            else
                                              Container(
                                                color:
                                                    colorScheme
                                                        .surfaceVariant, // Sử dụng surfaceVariant
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  size: 48,
                                                  color:
                                                      colorScheme
                                                          .onSurfaceVariant, // Sử dụng onSurfaceVariant
                                                ),
                                              ),
                                            Positioned.fill(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: colorScheme.shadow
                                                          .withOpacity(
                                                            0.1,
                                                          ), // Sử dụng shadow color
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
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                colorScheme
                                                    .onPrimary, // Text color trên primary background
                                            shadows: const [
                                              Shadow(
                                                color: Colors.black26,
                                                offset: Offset(1, 1),
                                                blurRadius: 2,
                                              ),
                                            ],
                                          ) ??
                                          TextStyle(
                                            // Fallback style
                                            fontWeight: FontWeight.w600,
                                            color:
                                                colorScheme
                                                    .onPrimary, // Text color trên primary background
                                            fontSize: 15,
                                            shadows: const [
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
          _buildBookSection(
            "Lịch sử đọc sách",
            myBooks,
            context,
          ), // Truyền context

          const SizedBox(height: 30),

          // Favorites Section
          _buildBookSection(
            "Sách được yêu thích",
            favoriteBooks,
            context,
          ), // Truyền context

          const SizedBox(height: 30),

          Text(
            "Thể loại",
            style:
                Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary, // Sử dụng primary color
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ) ??
                TextStyle(
                  // Fallback style
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary, // Sử dụng primary color
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
          _buildCategories(context),
        ],
      ),
    );
  }

  Widget _buildBookSection(
    String title,
    Future<List<Book>> futureBooks,
    BuildContext context,
  ) {
    // Thêm BuildContext
    final ColorScheme colorScheme =
        Theme.of(context).colorScheme; // Lấy ColorScheme từ theme

    return FutureBuilder<List<Book>>(
      future: futureBooks,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          ); // Sử dụng primary color
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "$title: Không có sách nào.",
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color:
                        colorScheme
                            .onSurfaceVariant, // Sử dụng onSurfaceVariant
                  ) ??
                  TextStyle(
                    // Fallback style
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color:
                        colorScheme
                            .onSurfaceVariant, // Sử dụng onSurfaceVariant
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
              style:
                  Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary, // Sử dụng primary color
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ) ??
                  TextStyle(
                    // Fallback style
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary, // Sử dụng primary color
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
                                (context) => BookDetailPage(
                                  bookId: book.id,
                                  user: widget.user,
                                ),
                          ),
                        ).then((_) => {reloadData()});
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
                                                    .surfaceVariant, // Sử dụng surfaceVariant
                                            child: Icon(
                                              Icons.broken_image,
                                              color:
                                                  colorScheme
                                                      .onSurfaceVariant, // Sử dụng onSurfaceVariant
                                            ),
                                          ),
                                    )
                                  else
                                    Container(
                                      width: 120,
                                      height: 160,
                                      color:
                                          colorScheme
                                              .surfaceVariant, // Sử dụng surfaceVariant
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color:
                                            colorScheme
                                                .onSurfaceVariant, // Sử dụng onSurfaceVariant
                                      ),
                                    ),
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: colorScheme.shadow
                                                .withOpacity(
                                                  0.1,
                                                ), // Sử dụng shadow color
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
                                style:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color:
                                          colorScheme
                                              .onSurface, // Sử dụng onSurface
                                    ) ??
                                    TextStyle(
                                      // Fallback style
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          colorScheme
                                              .onSurface, // Sử dụng onSurface
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
    final ColorScheme colorScheme =
        Theme.of(context).colorScheme; // Lấy ColorScheme từ theme

    final Map<String, String> categoryMapping = {
      'Tưởng tượng': 'fantasy',
      'Viễn tưởng': 'fiction',
      'Tâm lý tội phạm': 'crime',
      "Trẻ em": 'children',
      'Kinh dị': 'horror',
      'Drama': 'drama',
    };

    final categories = categoryMapping.keys.toList();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          categories.map((category) {
            final topic = categoryMapping[category];
            if (topic == null) {
              return const SizedBox.shrink();
            }
            final imgPath = 'assets/categories/$topic.jpg';
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => BooksByCategoryPage(
                          topic: topic,
                          user: widget.user,
                        ),
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
                    colorFilter: ColorFilter.mode(
                      colorScheme.onSurface.withOpacity(
                        0.5,
                      ), // Sử dụng onSurface với opacity
                      BlendMode.darken,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(
                        0.2,
                      ), // Sử dụng shadow color
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    category,
                    style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                          color:
                              colorScheme
                                  .onPrimary, // Text color trên primary background (màu trắng thường)
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(
                              color: Colors.black87,
                              offset: Offset(2, 2),
                              blurRadius: 3,
                            ),
                          ],
                        ) ??
                        TextStyle(
                          // Fallback style
                          fontSize: 18,
                          color:
                              colorScheme
                                  .onPrimary, // Text color trên primary background (màu trắng thường)
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(
                              color: Colors.black87,
                              offset: Offset(2, 2),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
