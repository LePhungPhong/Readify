import 'package:readify/database/db_helper.dart';
import 'package:readify/models/Phong/user_model.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart'; // Make sure you import the 'crypto' package

class AuthService {
  final AppDatabase _db = AppDatabase();

  // Method to hash the password
  String hashPassword(String password) {
    final bytes = utf8.encode(password); // Convert the password to bytes
    final digest = sha256.convert(bytes); // Hash using SHA256
    return digest.toString(); // Return the hashed password as a string
  }

  // Login method
  Future<UserModel?> login(String email, String password) async {
    final dbClient = await _db.db;

    final result = await dbClient.query(
      'Users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (result.isNotEmpty) {
      // Cast the 'password' field to String
      String hashedPasswordFromDatabase = result.first['password'] as String;

      // Hash the password entered by the user and compare with the stored hashed password
      if (hashPassword(password) == hashedPasswordFromDatabase) {
        // If the passwords match, return the user data
        return UserModel.fromMap(result.first);
      }
    }

    return null; // Return null if login fails
  }
}
