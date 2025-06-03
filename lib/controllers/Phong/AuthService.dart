import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:readify/database/db_helper.dart';
import 'package:readify/models/Phong/user_model.dart';
import 'package:readify/services/firebase_user_service.dart';
import 'package:readify/services/local_user_service.dart';
import 'package:readify/services/user_repository.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('users');
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  late final LocalUserService _localService;
  late final FirebaseUserService _firebaseService;
  late final UserRepository _userRepository;

  AuthService() {
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final database = await AppDatabase().initDatabase();
    _localService = LocalUserService(database);
    _firebaseService = FirebaseUserService();
    _userRepository = UserRepository(_localService, _firebaseService);
  }

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!credential.user!.emailVerified) {
        return null; // Email chưa được xác thực
      }

      final querySnapshot =
          await _usersCollection
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final userData = userDoc.data() as Map<String, dynamic>;
        final storedPassword = userData['password'] as String;

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

          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', user.id);

          return user;
        }
      }
      return null;
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
      // Kiểm tra email trùng lặp
      final querySnapshot =
          await _usersCollection
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return 'Email đã được sử dụng. Vui lòng chọn email khác.';
      }

      // Đăng ký với Firebase Authentication
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Gửi email xác thực
      await credential.user!.sendEmailVerification();

      final hashedPassword = hashPassword(password);
      final user = UserModel(
        id: const Uuid().v4().hashCode.abs(),
        email: email,
        password: hashedPassword,
        name: name,
        avatarUrl: avatarUrl,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      // Lưu vào Firestore
      await _usersCollection.doc(user.id.toString()).set(user.toMap());
      // Lưu vào SQLite
      await _localService.insertOrUpdateUser(user);
      // Đồng bộ từ Firestore
      await _userRepository.syncFromFirebase();

      // Lưu user_id vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', user.id);

      return null;
    } catch (e) {
      print('Đăng ký thất bại: $e');
      return 'Đăng ký thất bại: $e';
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Gửi email đặt lại mật khẩu thất bại: $e');
    }
  }

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
