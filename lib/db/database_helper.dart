import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/book_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<void> deleteDatabaseIfNeeded() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'books.db');
    await deleteDatabase(path);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    // await deleteDatabaseIfNeeded(); // chỉ cần khi dev
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
      CREATE TABLE books (
        id INTEGER PRIMARY KEY,
        title TEXT,
        authors TEXT,
        types TEXT,
        coverUrl TEXT,
        contentUrl TEXT,
        subjects TEXT,
        summaries TEXT,
        bookshelves TEXT,
        languages TEXT,
        isCopyright INTEGER,
        mediaType TEXT,
        downloadCount INTEGER,
        filePath TEXT,
        lastReadCfi TEXT
      )
    ''');
  }

  Future<void> insertBook(Book book, List<String> types) async {
    final db = await instance.database;

    await db.insert('books', {
      'id': book.id,
      'title': book.title,
      'authors': book.authors.join(','),
      'types': types.join(','),
      'coverUrl': book.coverUrl,
      'contentUrl': book.contentUrl,
      'subjects': book.subjects.join(','),
      'summaries': book.summaries.isNotEmpty ? book.summaries.join(", ") : '',
      'bookshelves': book.bookshelves.join(','),
      'languages': book.languages.join(','),
      'isCopyright': book.isCopyright ? 1 : 0,
      'mediaType': book.mediaType,
      'downloadCount': book.downloadCount,
      'filePath': book.filePath ?? '',
      'lastReadCfi': "",
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Book>> getBooks({String? type}) async {
    final db = await instance.database;
    List<Map<String, Object?>> result;

    if (type != null) {
      result = await db.query(
        'books',
        where: 'types LIKE ?',
        whereArgs: ['%$type%'],
      );
    } else {
      result = await db.query('books');
    }

    return result.map((json) => _fromJson(json)).toList();
  }

  Future<Book?> getBookById(int id) async {
    final db = await instance.database;
    final result = await db.query('books', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? _fromJson(result.first) : null;
  }

  Future<void> deleteBook(int id) async {
    final db = await instance.database;
    await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isBookExists(int id) async {
    final db = await instance.database;
    final result = await db.query('books', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty;
  }

  Future<void> updateBookFilePath(int bookId, String filePath) async {
    final db = await instance.database;
    await db.update(
      'books',
      {'filePath': filePath},
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  Book _fromJson(Map<String, Object?> json) {
    return Book(
      id: json['id'] as int,
      title: json['title'] as String,
      authors: (json['authors'] as String?)?.split(',') ?? [],
      types: (json['types'] as String?)?.split(',') ?? [],
      coverUrl: json['coverUrl'] as String?,
      contentUrl: json['contentUrl'] as String?,
      subjects: (json['subjects'] as String?)?.split(',') ?? [],
      summaries: (json['summaries'] as String?)?.split(',') ?? [],
      bookshelves: (json['bookshelves'] as String?)?.split(',') ?? [],
      languages: (json['languages'] as String?)?.split(',') ?? [],
      isCopyright: json['isCopyright'] == 1,
      mediaType: json['mediaType'] as String,
      downloadCount: json['downloadCount'] as int,
      lastReadCfi: null,
      filePath: json['filePath'] as String?,
    );
  }

  Future<void> updateLastCfi(int bookId, String cfi) async {
    final db = await database;
    await db.update(
      'books',
      {'lastReadCfi': cfi},
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  Future<String?> getLastCfi(int bookId) async {
    final db = await database;
    final result = await db.query(
      'books',
      columns: ['lastReadCfi'],
      where: 'id = ?',
      whereArgs: [bookId],
    );
    if (result.isNotEmpty) {
      return result.first['lastReadCfi'] as String?;
    }
    return null;
  }
}
