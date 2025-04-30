import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
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

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ReadingStatus (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id INTEGER,
        current_page INTEGER,
        is_bookmarked INTEGER
      );
    ''');

    await db.execute('''
    CREATE TABLE Users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE NOT NULL,
      password TEXT,
      name TEXT,
      avatar_url TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  ''');

    await db.execute('''
    CREATE TABLE Categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    );
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
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (category_id) REFERENCES Categories(id)
    );
  ''');

    await db.execute('''
    CREATE TABLE Bookmarks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      book_id INTEGER,
      page_number INTEGER,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES Users(id),
      FOREIGN KEY (book_id) REFERENCES Books(id)
    );
  ''');

    await db.execute('''
    CREATE TABLE Library (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      book_id INTEGER,
      added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES Users(id),
      FOREIGN KEY (book_id) REFERENCES Books(id)
    );
  ''');

    await db.execute('''
    CREATE TABLE Reviews (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      book_id INTEGER,
      rating INTEGER,
      comment TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES Users(id),
      FOREIGN KEY (book_id) REFERENCES Books(id)
    );
  ''');

    // Thêm dữ liệu mẫu
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
    });
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
}
