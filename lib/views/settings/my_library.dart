import 'package:flutter/material.dart';

class MyLibraryPage extends StatefulWidget {
  const MyLibraryPage({super.key});

  @override
  State<MyLibraryPage> createState() => _MyLibrarySectionState();
}

class _MyLibrarySectionState extends State<MyLibraryPage> {
  bool _isGridView = true;

  // Giả lập danh sách sách đã tải
  final List<Map<String, String>> _books = [
    {'title': 'Lập trình Flutter', 'author': 'Nguyễn Văn A'},
    {'title': 'Học máy cơ bản', 'author': 'Trần Thị B'},
    {'title': 'Deep Learning nâng cao', 'author': 'Lê Văn C'},
    {'title': 'Thiết kế UI/UX', 'author': 'Phạm D'},
    {'title': 'Data Science thực chiến', 'author': 'Ngô E'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Phần tiêu đề và nút đổi chế độ
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📁 Thư Viện Của Tôi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
                tooltip:
                    _isGridView
                        ? 'Hiển thị dạng danh sách'
                        : 'Hiển thị dạng lưới',
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
              ),
            ],
          ),
        ),

        // Phần mô tả
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "• Danh sách sách đã tải xuống hoặc đã thêm vào thư viện cá nhân.",
              ),
              Text("• Có thể hiển thị theo dạng lưới hoặc danh sách."),
              SizedBox(height: 12),
            ],
          ),
        ),

        // Phần hiển thị danh sách sách
        Expanded(child: _isGridView ? _buildGridView() : _buildListView()),
      ],
    );
  }

  // Hiển thị dạng lưới
  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _books.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final book = _books[index];
        return _buildBookCard(book);
      },
    );
  }

  // Hiển thị dạng danh sách
  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _books.length,
      itemBuilder: (context, index) {
        final book = _books[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.book),
            title: Text(book['title']!),
            subtitle: Text(book['author']!),
          ),
        );
      },
    );
  }

  // Card sách cho chế độ lưới
  Widget _buildBookCard(Map<String, String> book) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book_outlined, size: 40, color: Colors.deepOrange),
            const SizedBox(height: 10),
            Text(
              book['title']!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(book['author']!, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
