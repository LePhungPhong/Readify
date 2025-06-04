import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late final LocalUserService _localService;
  late final FirebaseUserService _firebaseService;
  late final UserRepository _userRepository;
  final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage(); // Thêm FlutterSecureStorage

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

  Future<UserModel?> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!credential.user!.emailVerified) {
        return null; // Email chưa được xác thực
      }

      await _userRepository.syncPasswordFromFirebase(email, password);

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
        if (storedPassword != hashedInputPassword) {
          await _updatePasswordInFirestore(email, password);
        }

        final user = UserModel.fromMap({
          'id': userData['id'] as int,
          'email': userData['email'] as String,
          'password': hashedInputPassword,
          'name': userData['name'] as String,
          'avatar_url': userData['avatar_url'] as String?,
          'created_at': userData['created_at'] as String?,
          'updated_at': userData['updated_at'] as String?,
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', user.id);

        // Lưu thông tin đăng nhập nếu rememberMe được bật
        if (rememberMe) {
          await _secureStorage.write(key: 'saved_email', value: email);
          await _secureStorage.write(
            key: 'saved_password',
            value: password,
          ); // Lưu mật khẩu gốc
          await prefs.setBool('remember_me', true);
        } else {
          await _secureStorage.delete(key: 'saved_email');
          await _secureStorage.delete(key: 'saved_password');
          await prefs.setBool('remember_me', false);
        }

        return user;
      }
      return null;
    } catch (e) {
      print('Đăng nhập thất bại: $e');
      return null;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // Người dùng hủy đăng nhập
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final auth.UserCredential authResult = await _firebaseAuth
          .signInWithCredential(credential);
      final auth.User? firebaseUser = authResult.user;

      if (firebaseUser == null) {
        return null;
      }

      final querySnapshot =
          await _usersCollection
              .where('email', isEqualTo: firebaseUser.email)
              .limit(1)
              .get();

      UserModel user;
      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final userData = userDoc.data() as Map<String, dynamic>;
        user = UserModel.fromMap({
          'id': userData['id'] as int,
          'email': userData['email'] as String,
          'password': userData['password'] as String? ?? '',
          'name': userData['name'] as String,
          'avatar_url':
              userData['avatar_url'] as String? ?? firebaseUser.photoURL,
          'created_at': userData['created_at'] as String?,
          'updated_at': userData['updated_at'] as String?,
        });
      } else {
        user = UserModel(
          id: const Uuid().v4().hashCode.abs(),
          email: firebaseUser.email!,
          password: '',
          name: firebaseUser.displayName ?? 'Người dùng Google',
          avatarUrl: firebaseUser.photoURL,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
        await _usersCollection.doc(user.id.toString()).set(user.toMap());
        await _localService.insertOrUpdateUser(user);
        await _userRepository.syncFromFirebase();
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', user.id);
      return user;
    } catch (e) {
      print('Đăng nhập bằng Google thất bại: $e');
      return null;
    }
  }

  Future<UserModel?> registerWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // Người dùng hủy đăng ký
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final auth.UserCredential authResult = await _firebaseAuth
          .signInWithCredential(credential);
      final auth.User? firebaseUser = authResult.user;

      if (firebaseUser == null) {
        return null;
      }

      final querySnapshot =
          await _usersCollection
              .where('email', isEqualTo: firebaseUser.email)
              .limit(1)
              .get();

      UserModel user;
      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final userData = userDoc.data() as Map<String, dynamic>;
        user = UserModel.fromMap({
          'id': userData['id'] as int,
          'email': userData['email'] as String,
          'password': userData['password'] as String? ?? '',
          'name': userData['name'] as String,
          'avatar_url':
              userData['avatar_url'] as String? ?? firebaseUser.photoURL,
          'created_at': userData['created_at'] as String?,
          'updated_at': userData['updated_at'] as String?,
        });
      } else {
        user = UserModel(
          id: const Uuid().v4().hashCode.abs(),
          email: firebaseUser.email!,
          password: '',
          name: firebaseUser.displayName ?? 'Người dùng Google',
          avatarUrl: firebaseUser.photoURL,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
        await _usersCollection.doc(user.id.toString()).set(user.toMap());
        await _localService.insertOrUpdateUser(user);
        await _userRepository.syncFromFirebase();
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', user.id);

      return user;
    } catch (e) {
      print('Đăng ký bằng Google thất bại: $e');
      throw Exception('Đăng ký bằng Google thất bại: $e');
    }
  }

  Future<void> _updatePasswordInFirestore(
    String email,
    String newPassword,
  ) async {
    try {
      final querySnapshot =
          await _usersCollection
              .where('email', isEqualTo: email)
              .limit(1)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        await userDoc.reference.update({
          'password': hashPassword(newPassword),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('Mật khẩu đã được cập nhật trong Firestore cho email: $email');
      }
    } catch (e) {
      print('Lỗi khi cập nhật mật khẩu trong Firestore: $e');
    }
  }

  Future<String?> register(
    String email,
    String password,
    String name,
    String? avatarUrl,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

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

      await _usersCollection.doc(user.id.toString()).set(user.toMap());
      await _localService.insertOrUpdateUser(user);
      await _userRepository.syncFromFirebase();

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

  // Lấy thông tin đăng nhập đã lưu
  Future<Map<String, String>?> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = await _secureStorage.read(key: 'saved_email');
    final password = await _secureStorage.read(key: 'saved_password');
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (rememberMe && email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }
}
