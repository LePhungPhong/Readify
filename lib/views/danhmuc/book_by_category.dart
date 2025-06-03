import 'package:flutter/material.dart';
import 'package:readify/controllers/book_controller.dart';
import 'package:readify/models/Phong/user_model.dart';
import 'package:readify/models/book_model.dart';
import 'package:readify/views/docsachs/detail_book.dart';

class BooksByCategoryPage extends StatefulWidget {
  final String topic;
  final UserModel user;

  const BooksByCategoryPage({
    required this.topic,
    required this.user,
    super.key,
  });

  @override
  State<BooksByCategoryPage> createState() => _BooksByCategoryPageState();
}

class _BooksByCategoryPageState extends State<BooksByCategoryPage> {
  final BookController _controller = BookController();
  final ScrollController _scrollController = ScrollController();
  List<Book> _books = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
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
    setState(() => _isLoading = true);
    try {
      final books = await _controller.getBooksByCategory(widget.topic);
      if (mounted) {
        setState(() {
          _books = books;
          _hasMore = _controller.nextUrl != null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải sách: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreBooks() async {
    if (!_hasMore || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);
    try {
      final moreBooks = await _controller.getNextPageByCategory();
      if (mounted) {
        setState(() {
          _books.addAll(moreBooks);
          _hasMore = _controller.nextUrl != null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải thêm sách: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildBookGridItem(Book book) {
    final textTheme =
        Theme.of(context).textTheme; // Access the theme's text styles

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BookDetailPage(bookId: book.id, user: widget.user),
          ),
        );
      },
      child: Column(
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
            style: textTheme.titleSmall?.copyWith(
              color: Colors.black87,
            ), // Apply titleSmall
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            book.authors.isNotEmpty
                ? book.authors.join(", ")
                : 'Tác giả không rõ',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ), // Apply bodyMedium
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme =
        Theme.of(context).textTheme; // Access the theme's text styles

    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        widget.topic.toUpperCase(),
                        style: textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                        ), // Apply headlineMedium
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
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 48,
                                  ),
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
                          // TODO: xử lý tìm kiếm
                        },
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sách (${_controller.totalCount ?? _books.length})',
                            style: textTheme.titleLarge?.copyWith(
                              color: const Color(0xFFBD5A5A),
                            ), // Apply titleLarge
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _books.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.55,
                                ),
                            itemBuilder:
                                (context, index) =>
                                    _buildBookGridItem(_books[index]),
                          ),
                          if (_isLoadingMore)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          if (!_hasMore && _books.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
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
