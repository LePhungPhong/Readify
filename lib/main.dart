import 'package:do_an_mobile/detail_book.dart';
import 'package:flutter/material.dart';
import 'package:do_an_mobile/read_book.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'app.db');

  await deleteDatabase(path);

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BookDetailPage(bookId: 1),
    ),
  );
}
