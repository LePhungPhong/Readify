import 'package:sqflite/sqflite.dart';
import '../models/Phong/user_model.dart';

class LocalUserService {
  final Database db;

  LocalUserService(this.db);

  Future<void> insertOrUpdateUser(UserModel user) async {
    await db.insert(
      'Users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserModel>> getAllUsers() async {
    final List<Map<String, dynamic>> maps = await db.query('Users');
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<void> deleteUser(String id) async {
    await db.delete('Users', where: 'id = ?', whereArgs: [id]);
  }
}
