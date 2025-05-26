import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:readify/models/Phong/user_model.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('users');

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      // Truy vấn Firestore để tìm người dùng theo email
      final querySnapshot =
          await _usersCollection
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final userData = userDoc.data() as Map<String, dynamic>;
        final storedPassword = userData['password'] as String;

        // So sánh mật khẩu mã hóa
        final hashedInputPassword = hashPassword(password);
        if (storedPassword == hashedInputPassword) {
          final user = UserModel.fromMap({
            'id': userData['id'] as int,
            'email': userData['email'] as String,
            'password': userData['password'] as String,
            'name': userData['name'] as String,
            'avatar_url': userData['avatar_url'] as String?,
            'created_at': userData['created_at'] as String?,
            'updated_at': userData['updated_at'] as String?,
          });
          // Lưu user_id vào SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', user.id);

          return user;
        }
      }
      return null; // Email hoặc mật khẩu không đúng
    } catch (e) {
      print('Đăng nhập thất bại: $e');
      return null;
    }
  }

  Future<String?> register(
    String email,
    String password,
    String name,
    String? avatarUrl,
  ) async {
    try {
      final querySnapshot =
          await _usersCollection
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return 'Email đã tồn tại.';
      }

      final hashedPassword = hashPassword(password);
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch,
        email: email,
        password: hashedPassword,
        name: name,
        avatarUrl: avatarUrl,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      await _usersCollection.doc(user.id.toString()).set(user.toMap());
      return null;
    } catch (e) {
      print('Đăng ký thất bại: $e');
      return 'Đăng ký thất bại: $e';
    }
  }

  // lấy thông tin người dùng hiện tại từ Firestore
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) {
      print('Không tìm thấy user_id trong SharedPreferences.');
      return null;
    }

    try {
      final doc = await _usersCollection.doc(userId.toString()).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel.fromMap(data);
      } else {
        print('Không tìm thấy user trong Firestore với ID: $userId');
      }
    } catch (e) {
      print('Lỗi khi lấy user từ Firestore: $e');
    }

    return null;
  }
}
