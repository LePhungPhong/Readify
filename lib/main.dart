import 'package:flutter/material.dart';
import 'views/home_view.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Ứng dụng đọc sách',
      home: HomeView(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
