import 'package:flutter/material.dart';
import 'book_list_view.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thư viện sách')),
      body: BookListView(),
    );
  }
}
