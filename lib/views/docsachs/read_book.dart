import 'package:flutter/material.dart';
import 'package:readify/database/db_helper.dart';
import 'dart:async';

class ReadingPage extends StatefulWidget {
  final int bookId;
  const ReadingPage({super.key, required this.bookId});

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  double fontSize = 16.0;
  bool _isDarkMode = false;
  bool _isBookmarked = false;
  int _currentPage = 0;

  List<String> pages = [];
  late PageController _pageController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadBook();
  }

  Future<void> _loadBook() async {
    print("Loading book with ID: ${widget.bookId}");
    final book = await AppDatabase().getBookById(widget.bookId);
    print("BOOK FOUND: $book");

    if (book == null || book['content'] == null) {
      setState(() {
        _isLoading = false;
        pages = ['Không tìm thấy nội dung sách.'];
      });
      return;
    }

    final content = book['content'] as String;
    pages = await _splitTextIntoPages(content, 3000);

    setState(() {
      _isLoading = false;
    });

    _pageController = PageController(initialPage: _currentPage);
  }

  Future<List<String>> _splitTextIntoPages(
    String fullText,
    int pageSize,
  ) async {
    final paragraphs = _splitChapters(fullText);
    List<String> resultPages = [];
    String currentPage = '';

    for (String paragraph in paragraphs) {
      if ((currentPage.length + paragraph.length + 1) <= pageSize) {
        currentPage += "$paragraph\n";
      } else {
        resultPages.add(currentPage.trim());
        currentPage = "$paragraph\n";
      }
    }

    if (currentPage.isNotEmpty) {
      resultPages.add(currentPage.trim());
    }

    return resultPages;
  }

  List<String> _splitChapters(String rawText) {
    final RegExp chapterRegex = RegExp(
      r'(CHAPTER\s+[IVXLCDM]+\.\s+)',
      caseSensitive: false,
    );
    String markedText = rawText.replaceAllMapped(
      chapterRegex,
      (match) => '<<<SPLIT>>>${match.group(0)!}',
    );

    List<String> chapters = markedText.split('<<<SPLIT>>>');
    if (!chapters.first.trim().toUpperCase().startsWith('CHAPTER')) {
      chapters.removeAt(0);
    }

    return chapters;
  }

  void _goToPage(double progress) {
    final targetPage = (progress * (pages.length - 1)).round();
    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? const Color(0xFF303030) : Colors.white;
    final textColor = _isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 189, 90, 90),
        title: const Text("Đọc Sách"),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
          ),
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () async {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });

              await AppDatabase().saveReadingStatus(
                widget.bookId,
                _currentPage,
                _isBookmarked,
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) async {
                        setState(() {
                          _currentPage = index;
                        });

                        await AppDatabase().saveReadingStatus(
                          widget.bookId,
                          _currentPage,
                          _isBookmarked,
                        );
                      },

                      itemCount: pages.length,
                      itemBuilder: (context, index) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            pages[index],
                            style: TextStyle(
                              fontSize: fontSize,
                              color: textColor,
                              fontFamily: 'Times New Roman',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Slider(
                    min: 0,
                    max: (pages.length - 1).toDouble(),
                    value: _currentPage.toDouble(),
                    onChanged: (value) {
                      _goToPage(value / (pages.length - 1));
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Trang ${_currentPage + 1} / ${pages.length}',
                      style: TextStyle(color: textColor),
                    ),
                  ),
                ],
              ),
    );
  }
}
