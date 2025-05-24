import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Phong/user_model.dart';

class FirebaseUserService {
  final CollectionReference usersCollection = FirebaseFirestore.instance
      .collection('users');

  Future<void> uploadUser(UserModel user) async {
    await usersCollection.doc(user.id.toString()).set(user.toMap());
  }

  Future<List<UserModel>> fetchAllUsers() async {
    final snapshot = await usersCollection.get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteUser(String id) async {
    await usersCollection.doc(id).delete();
  }
}
