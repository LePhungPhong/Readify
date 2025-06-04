import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:readify/models/book_model.dart';
import 'package:readify/views/docsachs/detail_book.dart';
import 'package:readify/models/Phong/user_model.dart';

class SearchBookPage extends StatefulWidget {
  final UserModel user;

  const SearchBookPage({required this.user, super.key});

  @override
  State<SearchBookPage> createState() => _SearchBookPageState();
}

class _SearchBookPageState extends State<SearchBookPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Book> _books = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _nextUrl;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _nextUrl != null) {
        _loadMoreBooks();
      }
    });
  }

  Future<void> _searchBooks(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _currentQuery = query;
    });

    final url = 'https://gutendex.com/books/?search=$query';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      final books =
          (data['results'] as List)
              .map((json) => Book.fromApiJson(json))
              .toList();

      setState(() {
        _books = books;
        _nextUrl = data['next'];
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tìm kiếm: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreBooks() async {
    if (_nextUrl == null) return;

    setState(() => _isLoadingMore = true);
    try {
      final response = await http.get(Uri.parse(_nextUrl!));
      final data = json.decode(response.body);

      final moreBooks =
          (data['results'] as List)
              .map((json) => Book.fromApiJson(json))
              .toList();

      setState(() {
        _books.addAll(moreBooks);
        _nextUrl = data['next'];
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải thêm sách: $e')));
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  Widget _buildBookGridItem(Book book) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetailPage(bookId: book.id, user: widget.user),
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
                      color: colorScheme.surfaceVariant,
                      child: Icon(
                        Icons.broken_image,
                        size: 48,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.title ?? 'Không có tiêu đề',
            style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            book.authors.isNotEmpty
                ? book.authors.join(", ")
                : 'Tác giả không rõ',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          style: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary),
          decoration: InputDecoration(
            hintText: 'Tìm sách...',
            hintStyle: TextStyle(color: colorScheme.onPrimary.withOpacity(0.7)),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(Icons.search, color: colorScheme.onPrimary),
              onPressed: () => _searchBooks(_searchController.text),
            ),
          ),
          onSubmitted: (value) => _searchBooks(value),
        ),
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              )
              : _books.isEmpty
              ? Center(child: Text('Không có kết quả cho "$_currentQuery"'))
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kết quả: ${_books.length} sách',
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        controller: _scrollController,
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
                    ),
                    if (_isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (_nextUrl == null && _books.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'Đã tải hết sách',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
    );
  }
}
