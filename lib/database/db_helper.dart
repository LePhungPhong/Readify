import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:readify/models/Phong/user_model.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDatabase();
    return _db!;
  }

  Future<Database> initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ReadingStatus (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id INTEGER,
        current_page INTEGER,
        is_bookmarked INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE Users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT,
        name TEXT,
        avatar_url TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT,
        description TEXT,
        category_id INTEGER,
        cover_image_url TEXT,
        file_url TEXT,
        content TEXT,
        created_at TEXT,
        FOREIGN KEY (category_id) REFERENCES Categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        book_id INTEGER,
        page_number INTEGER,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES Users(id),
        FOREIGN KEY (book_id) REFERENCES Books(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Library (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        book_id INTEGER,
        added_at TEXT,
        FOREIGN KEY (user_id) REFERENCES Users(id),
        FOREIGN KEY (book_id) REFERENCES Books(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        book_id INTEGER,
        rating INTEGER,
        comment TEXT,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES Users(id),
        FOREIGN KEY (book_id) REFERENCES Books(id)
      )
    ''');

    await db.insert('Categories', {'name': 'Tiểu thuyết'});

    await db.insert('Books', {
      'title': 'Cuốn Sách Mẫu',
      'author': 'Nguyễn Văn A',
      'description': 'Sách mẫu được gán cứng vào database.',
      'category_id': 1,
      'cover_image_url': '',
      'file_url': '',
      'content': '''CHAPTER I. GIỚI THIỆU

Đây là đoạn văn mẫu đầu tiên của cuốn sách. Nội dung có thể là bất kỳ thứ gì bạn muốn. 
Bạn có thể mở rộng và chia nhỏ nó thành các đoạn, hoặc phân chương bằng tiêu đề riêng.

CHAPTER II. TIẾP TỤC

Đây là chương tiếp theo trong sách mẫu. Nội dung này đang được lưu trực tiếp vào SQLite. 
Bạn có thể đọc offline mà không cần tải về từ internet.''',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE Users ADD COLUMN updated_at TEXT');
      await db.execute(
        "UPDATE Users SET updated_at = '1970-01-01T00:00:00.000Z' WHERE updated_at IS NULL",
      );
    }
  }

  Future<void> close() async {
    final database = await db;
    await database.close();
  }

  Future<void> saveReadingStatus(
    int bookId,
    int currentPage,
    bool isBookmarked,
  ) async {
    final database = await db;
    await database.insert('ReadingStatus', {
      'book_id': bookId,
      'current_page': currentPage,
      'is_bookmarked': isBookmarked ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getReadingStatus(int bookId) async {
    final database = await db;
    final result = await database.query(
      'ReadingStatus',
      where: 'book_id = ?',
      whereArgs: [bookId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'Users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getBookById(int id) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'Books',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getReadingHistory(int userId) async {
    final dbClient = await db;

    final result = await dbClient.rawQuery(
      '''
      SELECT 
        Books.title,
        Books.author,
        Library.added_at,
        ReadingStatus.current_page,
        ReadingStatus.is_bookmarked
      FROM Library
      JOIN Books ON Library.book_id = Books.id
      LEFT JOIN ReadingStatus ON Books.id = ReadingStatus.book_id
      WHERE Library.user_id = ?
      ORDER BY Library.added_at DESC
      ''',
      [userId],
    );

    return result;
  }

  Future<void> registerUser(
    String email,
    String password,
    String name,
    String avatarUrl,
  ) async {
    final dbClient = await db;
    await dbClient.insert('Users', {
      'email': email,
      'password': password,
      'name': name,
      'avatar_url': avatarUrl,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> validateUser(String email, String password) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'Users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      final storedPassword = result.first['password'] as String;
      return storedPassword == hashPassword(password);
    }
    return false;
  }

  Future<String?> registerUserSecure({
    required String email,
    required String password,
    required String name,
    required String avatarUrl,
  }) async {
    final dbClient = await db;

    final existingUser = await dbClient.query(
      'Users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (existingUser.isNotEmpty) {
      return 'Email đã tồn tại.';
    }

    final hashedPassword = hashPassword(password);

    try {
      await dbClient.insert('Users', {
        'email': email,
        'password': hashedPassword,
        'name': name,
        'avatar_url': avatarUrl,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.abort);
      return null;
    } catch (e) {
      return 'Đăng ký thất bại: $e';
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    final dbClient = await db;
    final result = await dbClient.query('Users');
    return result.map((e) => UserModel.fromMap(e)).toList();
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'Users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }
}
