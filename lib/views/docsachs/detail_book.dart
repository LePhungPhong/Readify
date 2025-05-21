import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:readify/views/docsachs/read_book.dart';
import 'package:readify/models/book_model.dart'; // Đảm bảo bạn có model Book

class BookDetailPage extends StatefulWidget {
  final int bookId;

  const BookDetailPage({super.key, required this.bookId});

  @override
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late Future<Book> _bookFuture;

  @override
  void initState() {
    super.initState();
    _bookFuture = fetchDetailBook(widget.bookId);
  }

  Future<Book> fetchDetailBook(int id) async {
    try {
      final response = await http.get(
        Uri.parse('https://gutendex.com/books/$id'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Book.fromJson(data);
      } else {
        throw Exception('Failed to load book detail');
      }
    } catch (e) {
      throw Exception('Error fetching book detail: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 189, 90, 90),
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
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        book.coverUrl ?? 'https://via.placeholder.com/150',
                        height: 300,
                        errorBuilder:
                            (_, __, ___) => const Icon(Icons.broken_image),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      book.authors.isNotEmpty
                          ? book.authors[0].name
                          : "Unknown Author",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          color:
                              index < 4
                                  ? const Color.fromARGB(255, 189, 90, 90)
                                  : Colors.grey,
                        );
                      }),
                    ),
                    const SizedBox(height: 5),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Thể loại:",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          book.subjects.isNotEmpty
                              ? book.subjects.first
                              : "Không rõ",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
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
                    const SizedBox(height: 5),
                    const Text(
                      "Available",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 189, 90, 90),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            print(book);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ReadingPage(
                                      bookUrl: book.contentUrl ?? "",
                                    ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              189,
                              90,
                              90,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 45,
                              vertical: 12,
                            ),
                            child: Text(
                              "Đọc",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.favorite_border_outlined,
                            color: Color.fromARGB(255, 189, 90, 90),
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Mô tả sách không có sẵn từ API Gutendex. Bạn có thể hiển thị đoạn mô tả tĩnh hoặc bỏ phần này.",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            );
          } else {
            return const Center(child: Text("Không tìm thấy dữ liệu sách."));
          }
        },
      ),
    );
  }
}
