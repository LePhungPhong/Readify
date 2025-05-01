import '../models/book_model.dart';
import '../db/database_helper.dart';

class LocalBookController {
  final db = DatabaseHelper.instance;

  Future<void> addToMyBooks(Book book) => db.insertBook(book, 'my_books');
  Future<void> addToFavorites(Book book) =>
      db.insertBook(book, 'favorite_books');

  Future<List<Book>> getMyBooks() => db.getBooks('my_books');
  Future<List<Book>> getFavorites() => db.getBooks('favorite_books');

  Future<void> removeFromMyBooks(int id) => db.deleteBook(id, 'my_books');
  Future<void> removeFromFavorites(int id) =>
      db.deleteBook(id, 'favorite_books');
}
