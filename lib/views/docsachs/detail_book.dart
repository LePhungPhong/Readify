import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:readify/models/Phong/user_model.dart';
import 'package:readify/models/book_model.dart';
import 'package:readify/views/docsachs/rating_bar_widget.dart';
import 'package:readify/views/docsachs/read_book.dart';
import 'package:readify/controllers/local_book_controller.dart';
import 'package:readify/views/settings/settings_page.dart';
// Không cần import 'package:readify/views/settings/setting.dart'; nếu nó không được dùng trực tiếp ở đây

class BookDetailPage extends StatefulWidget {
  final int bookId;
  final UserModel user;

  const BookDetailPage({super.key, required this.bookId, required this.user});

  @override
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late Future<Book> _bookFuture;
  final LocalBookController _localBookController = LocalBookController();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _bookFuture = _loadBookAndFavorite(widget.bookId);
  }

  Future<Book> _loadBookAndFavorite(int id) async {
    Book book = await _getBook(id);
    bool fav = await _localBookController.isBookIn("favorite_books", id);
    if (mounted) {
      setState(() {
        _isFavorite = fav;
      });
    }
    return book;
  }

  Future<Book> _getBook(int id) async {
    try {
      Book? bookFromDb = await _localBookController.getBookById(id);
      if (bookFromDb != null) {
        print('Lấy sách từ DB id=$id');
        return bookFromDb;
      }

      print('Fetch sách từ API id=$id');
      final response = await http.get(
        Uri.parse('https://gutendex.com/books/$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Book book = Book.fromApiJson(data);
        return book;
      } else {
        throw Exception('Không thể tải thông tin sách từ API.');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy dữ liệu sách: $e');
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.onBackground.withOpacity(
              0.7,
            ), // Using onBackground with opacity
          ), // Icon size can remain hardcoded or be part of a separate icon theme
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              "$label: $value",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color:
                    Theme.of(
                      context,
                    ).colorScheme.onBackground, // Using onBackground
              ), // Sử dụng bodyMedium (mặc định 14)
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(
            context,
          ).colorScheme.background, // Using theme background color
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).colorScheme.primary, // Using theme primary color
        // Sử dụng style từ Theme.of(context).appBarTheme.titleTextStyle hoặc titleLarge
        title: Text(
          "Readify",
          style:
              Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ) ?? // Using onPrimary
              Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ), // Using onPrimary
        ),
        centerTitle: true,
        leading: BackButton(
          color: Theme.of(context).colorScheme.onPrimary,
        ), // Using onPrimary
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.onPrimary,
            ), // Using onPrimary
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Book>(
        future: _bookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final book = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      book.coverUrl ?? 'https://via.placeholder.com/150',
                      height: 280,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 100),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ), // Sử dụng headlineSmall (mặc định 24)
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.authors.isNotEmpty
                        ? book.authors.join(", ")
                        : "Tác giả không rõ",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground
                          .withOpacity(0.7), // Using onBackground with opacity
                    ), // Sử dụng bodyMedium (mặc định 14)
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        color:
                            index < 4
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary // Using primary for stars
                                : Colors.grey[300],
                        size: 18, // Icon size
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    Icons.category,
                    "Thể loại",
                    book.subjects.isNotEmpty ? book.subjects.first : "Không rõ",
                  ),
                  _buildInfoRow(
                    Icons.language,
                    "Ngôn ngữ",
                    book.languages.join(", "),
                  ),
                  _buildInfoRow(
                    Icons.bookmark,
                    "Kệ sách",
                    book.bookshelves.isNotEmpty
                        ? book.bookshelves.join(", ")
                        : "Không rõ",
                  ),
                  _buildInfoRow(
                    Icons.lock_open,
                    "Bản quyền",
                    book.isCopyright ? "Có bản quyền" : "Không bản quyền",
                  ),
                  _buildInfoRow(
                    Icons.file_present,
                    "Loại dữ liệu",
                    book.mediaType,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            var bookInDb = await _localBookController
                                .getBookById(book.id);
                            if (bookInDb == null) {
                              await _localBookController.addBookTo(
                                "my_books",
                                book,
                              );
                              print('Đã lưu sách id=${book.id} vào my_books');
                            } else {
                              print('Sách id=${book.id} đã có trong my_books');
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ReadingPage(
                                      bookId: book.id,
                                      bookUrl: book.contentUrl ?? "",
                                    ),
                              ),
                            );
                          } catch (e) {
                            print("Lỗi khi mở sách: $e");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(
                                context,
                              ).colorScheme.primary, // Using primary color
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                          shape: const BeveledRectangleBorder(),
                        ),
                        child: Text(
                          "Đọc",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimary, // Using onPrimary
                          ), // Sử dụng bodyLarge (mặc định 16)
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () async {
                          try {
                            if (_isFavorite) {
                              await _localBookController.removeBookFrom(
                                "favorite_books",
                                book.id,
                              );
                              if (!mounted) return;
                              setState(() {
                                _isFavorite = false;
                              });
                            } else {
                              await _localBookController.addBookTo(
                                "favorite_books",
                                book,
                              );
                              if (!mounted) return;
                              setState(() {
                                _isFavorite = true;
                              });
                              print("Đã thêm vào Sách yêu thích của tôi");
                            }
                          } catch (e) {
                            print("Lỗi khi thay đổi trạng thái yêu thích: $e");
                          }
                        },
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.primary, // Using primary color
                          size: 28, // Icon size
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Giới thiệu sách",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.primary, // Using primary color
                      ), // Sử dụng titleMedium (mặc định 16)
                    ),
                  ),
                  const SizedBox(height: 10),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text(
                    book.summaries.isNotEmpty
                        ? book.summaries.join(", ")
                        : "Không có mô tả.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color:
                          Theme.of(
                            context,
                          ).colorScheme.onBackground, // Using onBackground
                    ), // Sử dụng bodyMedium (mặc định 14)
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "Đánh giá và bình luận",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          Theme.of(
                            context,
                          ).colorScheme.primary, // Using primary color
                    ), // Sử dụng titleMedium (mặc định 16)
                  ),
                  const SizedBox(height: 10),
                  RatingBarWidget(
                    bookId: widget.bookId,
                    user: widget.user,
                  ), // Passing primary color to RatingBarWidget
                  const SizedBox(height: 30),
                ],
              ),
            );
          } else {
            return const Center(child: Text("Không tìm thấy dữ liệu sách."));
          }
        },
      ),
    );
  }
}
