import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class BookService {
  // Thuộc tính để lưu trữ thông tin phân trang
  int? totalCount; // Tổng số sách
  String? nextUrl; // URL cho trang tiếp theo
  String? previousUrl; // URL cho trang trước đó

  // Reset các giá trị phân trang khi fetch mới
  void _resetPagination() {
    totalCount = null;
    nextUrl = null;
    previousUrl = null;
  }

  // Fetch danh sách sách (không theo category)
  Future<List<Book>> fetchBooks({int page = 1}) async {
    try {
      _resetPagination(); // Reset pagination khi fetch mới
      final response = await http.get(
        Uri.parse('https://gutendex.com/books/?page=$page'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        totalCount = data['count'] ?? 0; // Lưu tổng số sách
        nextUrl = data['next']; // Lưu URL trang tiếp theo
        previousUrl = data['previous']; // Lưu URL trang trước
        final List books = data['results'] ?? [];
        return books.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      throw Exception('Error fetching books: $e');
    }
  }

  // Fetch sách theo category, hỗ trợ phân trang
  Future<List<Book>> fetchBooksByCategory(
    String category, {
    int page = 1,
  }) async {
    try {
      _resetPagination(); // Reset pagination khi fetch mới
      final url = 'https://gutendex.com/books/?topic=$category&page=$page';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        totalCount = data['count'] ?? 0; // Lưu tổng số sách
        nextUrl = data['next']; // Lưu URL trang tiếp theo
        previousUrl = data['previous']; // Lưu URL trang trước
        final List books = data['results'] ?? [];
        return books.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load books by category');
      }
    } catch (e) {
      throw Exception('Error fetching books by category: $e');
    }
  }

  // Fetch trang tiếp theo (dựa trên nextUrl)
  Future<List<Book>> fetchNextPage() async {
    if (nextUrl == null) {
      return []; // Không có trang tiếp theo
    }
    try {
      final response = await http.get(Uri.parse(nextUrl!));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        totalCount = data['count'] ?? 0; // Cập nhật tổng số sách
        nextUrl = data['next']; // Cập nhật URL trang tiếp theo
        previousUrl = data['previous']; // Cập nhật URL trang trước
        final List books = data['results'] ?? [];
        return books.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load next page');
      }
    } catch (e) {
      throw Exception('Error fetching next page: $e');
    }
  }

  // Fetch trang trước (dựa trên previousUrl)
  Future<List<Book>> fetchPreviousPage() async {
    if (previousUrl == null) {
      return []; // Không có trang trước
    }
    try {
      final response = await http.get(Uri.parse(previousUrl!));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        totalCount = data['count'] ?? 0; // Cập nhật tổng số sách
        nextUrl = data['next']; // Cập nhật URL trang tiếp theo
        previousUrl = data['previous']; // Cập nhật URL trang trước
        final List books = data['results'] ?? [];
        return books.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load previous page');
      }
    } catch (e) {
      throw Exception('Error fetching previous page: $e');
    }
  }
}
