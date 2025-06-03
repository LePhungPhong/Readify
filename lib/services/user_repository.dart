import 'package:shared_preferences/shared_preferences.dart';
import '../models/Phong/user_model.dart';
import '../services/local_user_service.dart';
import '../services/firebase_user_service.dart';

class UserRepository {
  final LocalUserService localService;
  final FirebaseUserService firebaseService;

  UserRepository(this.localService, this.firebaseService);

  Future<void> syncToFirebase() async {
    try {
      final localUsers = await localService.getAllUsers();
      for (var user in localUsers) {
        await firebaseService.uploadUser(user);
      }
      print('Đồng bộ lên Firebase thành công');
    } catch (e) {
      print('Lỗi khi đồng bộ lên Firebase: $e');
      throw e;
    }
  }

  Future<void> syncFromFirebase() async {
    try {
      final snapshot =
          await firebaseService.usersCollection
              .where('updated_at', isGreaterThan: await _getLastSyncTime())
              .get();
      final firebaseUsers =
          snapshot.docs
              .map(
                (doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();

      for (var user in firebaseUsers) {
        await localService.insertOrUpdateUser(user);
      }

      await _updateLastSyncTime();
      print('Đồng bộ từ Firebase thành công');
    } catch (e) {
      print('Lỗi khi đồng bộ từ Firebase: $e');
      throw e;
    }
  }

  Future<void> uploadUserToFirebase(UserModel user) async {
    try {
      final userMap = user.toMap();
      userMap['updated_at'] = DateTime.now().toIso8601String();
      await firebaseService.uploadUser(UserModel.fromMap(userMap));
      print('User uploaded to Firebase successfully');
    } catch (e) {
      print('Failed to upload user: $e');
      throw e;
    }
  }

  Future<String> _getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_sync_time') ?? '2023-01-01T00:00:00Z';
  }

  Future<void> _updateLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_sync_time', DateTime.now().toIso8601String());
  }

  Future<void> syncPasswordFromFirebase(
    String email,
    String newPassword,
  ) async {
    try {
      final snapshot =
          await firebaseService.usersCollection
              .where('email', isEqualTo: email)
              .limit(1)
              .get();
      if (snapshot.docs.isNotEmpty) {
        final userData = snapshot.docs.first.data() as Map<String, dynamic>;
        final user = UserModel.fromMap(userData);
        user.password =
            newPassword; // Sử dụng setter để cập nhật, đã băm trong UserModel
        await localService.insertOrUpdateUser(user);
        print('Đồng bộ mật khẩu mới cho email $email thành công');
      } else {
        print('Không tìm thấy người dùng với email: $email');
      }
    } catch (e) {
      print('Lỗi khi đồng bộ mật khẩu từ Firebase: $e');
      throw e;
    }
  }
}
