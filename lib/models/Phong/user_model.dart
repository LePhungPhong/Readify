import 'dart:convert';
import 'package:crypto/crypto.dart';

class UserModel {
  final int id;
  final String email;
  String _password; // Biến private với getter/setter
  final String name;
  final String? avatarUrl;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required String password,
    required this.name,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  }) : _password = password;

  String get password => _password;

  set password(String newPassword) {
    _password = hashPassword(newPassword); // Băm mật khẩu trước khi gán
  }

  // Hàm băm mật khẩu
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': _password,
      'name': name,
      'avatar_url': avatarUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      email: map['email'] as String,
      password: map['password'] as String,
      name: map['name'] as String,
      avatarUrl: map['avatar_url'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }
}
