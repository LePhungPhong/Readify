import '../models/book_model.dart';
import '../services/book_service.dart';

class BookController {
  final BookService _service = BookService();
  List<Book> _books = []; // Lưu trữ danh sách sách hiện tại
  List<Book> _booksByCategory = []; // Lưu trữ danh sách sách theo category

  // Getter để truy cập các thuộc tính từ BookService
  int? get totalCount => _service.totalCount;
  String? get nextUrl => _service.nextUrl;
  String? get previousUrl => _service.previousUrl;

  // Reset danh sách sách khi fetch mới
  void _resetBooks() {
    _books = [];
  }

  void _resetBooksByCategory() {
    _booksByCategory = [];
  }

  // Fetch danh sách sách (không theo category)
  Future<List<Book>> getBooks({int page = 1}) async {
    try {
      _resetBooks(); // Reset danh sách khi fetch mới
      final books = await _service.fetchBooks(page: page);
      _books.addAll(books); // Lưu vào danh sách hiện tại
      return _books;
    } catch (e) {
      throw Exception('Error fetching books: $e');
    }
  }

  // Fetch sách theo category
  Future<List<Book>> getBooksByCategory(String type, {int page = 1}) async {
    try {
      _resetBooksByCategory(); // Reset danh sách khi fetch mới
      final books = await _service.fetchBooksByCategory(type, page: page);
      _booksByCategory.addAll(books); // Lưu vào danh sách hiện tại
      return _booksByCategory;
    } catch (e) {
      throw Exception('Error fetching books by category: $e');
    }
  }

  // Fetch trang tiếp theo (dành cho sách không theo category)
  Future<List<Book>> getNextPage() async {
    try {
      final moreBooks = await _service.fetchNextPage();
      _books.addAll(moreBooks); // Nối thêm sách vào danh sách hiện tại
      return _books;
    } catch (e) {
      throw Exception('Error fetching next page: $e');
    }
  }

  // Fetch trang trước (dành cho sách không theo category)
  Future<List<Book>> getPreviousPage() async {
    try {
      final previousBooks = await _service.fetchPreviousPage();
      _books = previousBooks; // Cập nhật danh sách sách
      return _books;
    } catch (e) {
      throw Exception('Error fetching previous page: $e');
    }
  }

  // Fetch trang tiếp theo (dành cho sách theo category)
  Future<List<Book>> getNextPageByCategory() async {
    try {
      final moreBooks = await _service.fetchNextPage();
      _booksByCategory.addAll(
        moreBooks,
      ); // Nối thêm sách vào danh sách hiện tại
      return _booksByCategory;
    } catch (e) {
      throw Exception('Error fetching next page by category: $e');
    }
  }

  // Fetch trang trước (dành cho sách theo category)
  Future<List<Book>> getPreviousPageByCategory() async {
    try {
      final previousBooks = await _service.fetchPreviousPage();
      _booksByCategory = previousBooks; // Cập nhật danh sách sách
      return _booksByCategory;
    } catch (e) {
      throw Exception('Error fetching previous page by category: $e');
    }
  }

  // Getter để truy cập danh sách sách hiện tại
  List<Book> get currentBooks => _books;
  List<Book> get currentBooksByCategory => _booksByCategory;
}
