import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:readify/views/docsachs/read_book.dart';
import 'package:readify/models/book_model.dart';
import 'package:readify/controllers/local_book_controller.dart';

class BookDetailPage extends StatefulWidget {
  final int bookId;

  const BookDetailPage({super.key, required this.bookId});

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
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              "$label: $value",
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFBD5A5A),
        title: const Text(
          "Readify",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
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
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.authors.isNotEmpty
                        ? book.authors.join(", ")
                        : "Tác giả không rõ",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        color:
                            index < 4
                                ? const Color(0xFFBD5A5A)
                                : Colors.grey[300],
                        size: 18,
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
                          backgroundColor: const Color(0xFFBD5A5A),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                          shape: const BeveledRectangleBorder(),
                        ),
                        child: const Text(
                          "Đọc",
                          style: TextStyle(fontSize: 16, color: Colors.white),
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
                          color: const Color(0xFFBD5A5A),
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Giới thiệu sách",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFBD5A5A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text(
                    book.summaries.isNotEmpty
                        ? book.summaries.join(", ")
                        : "Không có mô tả.",
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 40),
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
