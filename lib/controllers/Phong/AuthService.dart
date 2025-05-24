import 'package:readify/database/db_helper.dart';
import 'package:readify/models/Phong/user_model.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthService {
  final AppDatabase _db = AppDatabase();

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserModel?> login(String email, String password) async {
    final dbClient = await _db.db;

    final result = await dbClient.query(
      'Users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (result.isNotEmpty) {
      String hashedPasswordFromDatabase = result.first['password'] as String;
      if (hashPassword(password) == hashedPasswordFromDatabase) {
        return UserModel.fromMap(result.first);
      }
    }

    return null;
  }
}
