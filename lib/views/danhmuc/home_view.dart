import 'package:flutter/material.dart';
import 'package:readify/views/about_page/user_info_screen.dart';
import 'book_list_view.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thư viện sách'),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserInfoScreen()),
            );
          },
          icon: Icon(Icons.account_circle, size: 32),
        ),
      ),
      body: BookListView(),
    );
  }
}
