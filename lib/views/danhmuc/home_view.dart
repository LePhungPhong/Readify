import 'package:flutter/material.dart';
import 'package:readify/models/Phong/user_model.dart';
import 'package:readify/views/about_page/user_info_screen.dart';
import 'book_list_view.dart';

class HomeView extends StatelessWidget {
  final UserModel user;

  const HomeView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thư viện sách'),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserInfoScreen(user: user),
              ),
            );
          },
          icon: Icon(Icons.account_circle, size: 32),
        ),
      ),
      body: BookListView(user: user),
    );
  }
}
