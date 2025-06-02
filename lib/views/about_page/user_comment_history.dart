import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:readify/models/Phong/user_model.dart';

class UserCommentHistory extends StatelessWidget {
  final UserModel user;

  const UserCommentHistory({super.key, required this.user});

  Future<List<Map<String, dynamic>>> _fetchUserComments() async {
    final booksSnapshot =
        await FirebaseFirestore.instance.collection('books').get();

    List<Map<String, dynamic>> userComments = [];

    for (var bookDoc in booksSnapshot.docs) {
      final commentsRef = bookDoc.reference.collection('comments');
      final commentsSnapshot =
          await commentsRef
              .where('userId', isEqualTo: user.id)
              .orderBy('timestamp', descending: true)
              .get();

      for (var commentDoc in commentsSnapshot.docs) {
        final data = commentDoc.data();
        userComments.add({
          'bookId': bookDoc.id,
          'bookTitle': bookDoc['title'] ?? 'Không rõ',
          'content': data['content'],
          'rating': data['rating'],
          'timestamp': data['timestamp'],
        });
      }
    }

    return userComments;
  }

  Widget _buildStarRow(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          Icons.star,
          size: 14,
          color: index < rating ? Colors.orange : Colors.grey,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchUserComments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());

        final comments = snapshot.data ?? [];

        if (comments.isEmpty) {
          return const Text("Bạn chưa có bình luận nào.");
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "📄 Lịch sử bình luận của bạn",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...comments.map((comment) {
              final date = DateFormat(
                'dd/MM/yyyy HH:mm',
              ).format(DateTime.parse(comment['timestamp']));
              return Card(
                child: ListTile(
                  title: Text(comment['bookTitle']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(comment['content']),
                      _buildStarRow(comment['rating']),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
