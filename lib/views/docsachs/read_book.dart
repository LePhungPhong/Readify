import 'dart:io';
import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ReadingPage extends StatefulWidget {
  final String bookUrl;
  final int bookId;

  const ReadingPage({super.key, required this.bookUrl, required this.bookId});

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  late EpubController _epubController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final file = await _loadOrDownloadFile();

      if (!mounted) return;

      _epubController = EpubController(document: EpubDocument.openFile(file));

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('[ReadingPage] Lỗi tải epub: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<File> _loadOrDownloadFile() async {
    final dir = await getApplicationDocumentsDirectory();
    print('${dir.path}/book_${widget.bookId}.epub');
    final filePath = '${dir.path}/book_${widget.bookId}.epub';
    final file = File(filePath);

    if (await file.exists()) {
      return file;
    } else {
      final response = await http.get(Uri.parse(widget.bookUrl));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        throw Exception('Không tải được EPUB (mã ${response.statusCode})');
      }
    }
  }

  @override
  void dispose() {
    _epubController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("📖 Đọc Sách")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: EpubViewActualChapter(
          controller: _epubController,
          builder:
              (chapterValue) => Text(
                'Chapter: ' +
                    (chapterValue?.chapter?.Title
                            ?.replaceAll('\n', '')
                            .trim() ??
                        ''),
                textAlign: TextAlign.start,
              ),
        ),
      ),
      drawer: Drawer(
        child: EpubViewTableOfContents(controller: _epubController),
      ),
      body: EpubView(controller: _epubController),
    );
  }
}
