import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/book_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('books.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE my_books (
        id INTEGER PRIMARY KEY,
        title TEXT,
        coverUrl TEXT,
        contentUrl TEXT,
        subjects TEXT,
        summaries TEXT,
        bookshelves TEXT,
        languages TEXT,
        isCopyright INTEGER,
        mediaType TEXT,
        downloadCount INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE favorite_books (
        id INTEGER PRIMARY KEY,
        title TEXT,
        coverUrl TEXT,
        contentUrl TEXT,
        subjects TEXT,
        summaries TEXT,
        bookshelves TEXT,
        languages TEXT,
        isCopyright INTEGER,
        mediaType TEXT,
        downloadCount INTEGER
      )
    ''');
  }

  Future<void> insertBook(Book book, String table) async {
    final db = await instance.database;

    // Convert subjects, bookshelves, and languages to strings if they're lists
    final subjects = book.subjects.join(',');
    final summaries = book.summaries.join(',');
    final bookshelves = book.bookshelves.join(',');
    final languages = book.languages.join(',');

    await db.insert(table, {
      'id': book.id,
      'title': book.title,
      'coverUrl': book.coverUrl,
      'contentUrl': book.contentUrl,
      'subjects': subjects,
      'summaries': summaries,
      'bookshelves': bookshelves,
      'languages': languages,
      'isCopyright': book.isCopyright ? 1 : 0, // Convert boolean to integer
      'mediaType': book.mediaType,
      'downloadCount': book.downloadCount,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Book>> getBooks(String table) async {
    final db = await instance.database;
    final result = await db.query(table);

    return result.map((json) {
      // Safely cast the fields to String? before calling .split()
      final subjects = (json['subjects'] as String?)?.split(',') ?? [];
      final summaries = (json['summaries'] as String?)?.split(',') ?? [];
      final bookshelves = (json['bookshelves'] as String?)?.split(',') ?? [];
      final languages = (json['languages'] as String?)?.split(',') ?? [];

      return Book(
        id: json['id'] as int,
        title: json['title'] as String,
        authors: [], // You can update this if you have author data
        coverUrl: json['coverUrl'] as String?,
        contentUrl: json['contentUrl'] as String?,
        subjects: subjects,
        summaries: summaries,
        bookshelves: bookshelves,
        languages: languages,
        isCopyright:
            json['isCopyright'] == 1, // Convert integer back to boolean
        mediaType: json['mediaType'] as String,
        downloadCount: json['downloadCount'] as int,
      );
    }).toList();
  }

  Future<void> deleteBook(int id, String table) async {
    final db = await instance.database;
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
