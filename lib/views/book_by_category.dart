import 'package:flutter/material.dart';
import 'package:readify/controllers/book_controller.dart';
import 'package:readify/models/book_model.dart';

class BooksByCategoryPage extends StatefulWidget {
  final String topic;

  const BooksByCategoryPage({required this.topic});

  @override
  _BooksByCategoryPageState createState() => _BooksByCategoryPageState();
}

class _BooksByCategoryPageState extends State<BooksByCategoryPage> {
  final BookController _controller = BookController();
  final ScrollController _scrollController = ScrollController();
  List<Book> _books = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    // Load dữ liệu ban đầu
    _loadBooks();
    // Thêm listener để phát hiện khi kéo xuống cuối danh sách
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMore) {
        _loadMoreBooks();
      }
    });
  }

  Future<void> _loadBooks() async {
    try {
      final books = await _controller.getBooksByCategory(widget.topic);
      if (mounted) {
        // Kiểm tra xem widget còn tồn tại không
        setState(() {
          _books = books;
          _hasMore = _controller.nextUrl != null;
        });
      }
    } catch (e) {
      if (mounted) {
        // Kiểm tra trước khi sử dụng context
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading books: $e')));
      }
    }
  }

  Future<void> _loadMoreBooks() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final moreBooks = await _controller.getNextPageByCategory();
      if (mounted) {
        // Kiểm tra xem widget còn tồn tại không
        setState(() {
          _books = moreBooks;
          _hasMore = _controller.nextUrl != null;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // Kiểm tra trước khi sử dụng context
        setState(() {
          _isLoadingMore = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading more books: $e')));
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Header với hình nền và tiêu đề
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.topic.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/categories/${widget.topic}.jpg',
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 48),
                        ),
                  ),
                  Container(color: Colors.black.withOpacity(0.4)),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  // Xử lý tìm kiếm
                },
              ),
            ],
          ),
          // Nội dung chính
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề "Sách (tổng số sách)"
                  Text(
                    'Sách (${_controller.totalCount ?? 0})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFBD5A5A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Danh sách sách dạng lưới 2 cột
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.55,
                        ),
                    itemCount: _books.length,
                    itemBuilder: (context, index) {
                      final book = _books[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                book.coverUrl ?? '',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.broken_image,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            book.title ?? 'Không có tiêu đề',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            book.authors.isNotEmpty
                                ? book.authors[0].name ?? 'Tác giả không rõ'
                                : 'Tác giả không rõ',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    },
                  ),
                  // Hiển thị loading indicator khi đang fetch thêm dữ liệu
                  if (_isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  // Thông báo khi không còn dữ liệu để load
                  if (!_hasMore && _books.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: Text('Đã tải hết sách')),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
