import '../models/book_model.dart';
import '../db/database_helper.dart';

class LocalBookController {
  final DatabaseHelper db = DatabaseHelper.instance;

  /// Thêm sách vào database với một loại (type)
  Future<void> addBookTo(String type, Book book) async {
    final existingBook = await db.getBookById(book.id);
    List<String> updatedTypes = [];

    if (existingBook != null) {
      updatedTypes = List<String>.from(existingBook.types);
      if (!updatedTypes.contains(type)) {
        updatedTypes.add(type);
      } else {
        // Đã có type rồi, không cần thêm
        return;
      }

      if (updatedTypes.length == 0) {
        await db.deleteBook(book.id);
        return;
      }

      // Tạo bản mới với updatedTypes
      final updatedBook = Book(
        id: book.id,
        title: book.title,
        authors: book.authors,
        types: updatedTypes,
        coverUrl: book.coverUrl,
        contentUrl: book.contentUrl,
        subjects: book.subjects,
        summaries: book.summaries,
        bookshelves: book.bookshelves,
        languages: book.languages,
        isCopyright: book.isCopyright,
        mediaType: book.mediaType,
        downloadCount: book.downloadCount,
        filePath: book.filePath,
        lastReadCfi: book.lastReadCfi,
      );

      await db.insertBook(updatedBook, updatedTypes);
    } else {
      updatedTypes = [type];
      final newBook = Book(
        id: book.id,
        title: book.title,
        authors: book.authors,
        types: updatedTypes,
        coverUrl: book.coverUrl,
        contentUrl: book.contentUrl,
        subjects: book.subjects,
        summaries: book.summaries,
        bookshelves: book.bookshelves,
        languages: book.languages,
        isCopyright: book.isCopyright,
        mediaType: book.mediaType,
        downloadCount: book.downloadCount,
        filePath: book.filePath,
        lastReadCfi: book.lastReadCfi,
      );

      await db.insertBook(newBook, updatedTypes);
    }
  }

  /// Xóa sách khỏi một loại (type)
  Future<void> removeBookFrom(String type, int id) async {
    final book = await db.getBookById(id);
    if (book != null) {
      final updatedTypes = book.types.where((t) => t != type).toList();

      if (updatedTypes.isEmpty) {
        // Không còn loại nào -> xóa sách khỏi DB
        await db.deleteBook(id);
      } else {
        // Tạo lại sách với loại mới
        final updatedBook = Book(
          id: book.id,
          title: book.title,
          authors: book.authors,
          types: updatedTypes,
          coverUrl: book.coverUrl,
          contentUrl: book.contentUrl,
          subjects: book.subjects,
          summaries: book.summaries,
          bookshelves: book.bookshelves,
          languages: book.languages,
          isCopyright: book.isCopyright,
          mediaType: book.mediaType,
          downloadCount: book.downloadCount,
          filePath: book.filePath,
          lastReadCfi: book.lastReadCfi,
        );

        await db.insertBook(updatedBook, updatedTypes);
      }
    }
  }

  /// Lấy sách theo type
  Future<List<Book>> getBooksByType(String type) async {
    return await db.getBooks(type: type);
  }

  /// Kiểm tra sách có thuộc type không
  Future<bool> isBookIn(String type, int id) async {
    final book = await db.getBookById(id);
    return book?.types.contains(type) ?? false;
  }

  /// Lấy sách theo ID
  Future<Book?> getBookById(int id) async {
    return await db.getBookById(id);
  }

  /// Xóa hoàn toàn sách khỏi database
  Future<void> deleteBook(int id) async {
    await db.deleteBook(id);
  }
}
