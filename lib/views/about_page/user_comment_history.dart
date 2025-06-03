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
    final textTheme = Theme.of(context).textTheme; // Access TextTheme here

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchUserComments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());

        final comments = snapshot.data ?? [];

        if (comments.isEmpty) {
          return Center(
            child: Text(
              "Bạn chưa có bình luận nào.",
              // ONLY MODIFYING FONT SIZE
              style: textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ), // Original was default Text size (often 14-16)
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📄 Lịch sử bình luận của bạn",
              // ONLY MODIFYING FONT SIZE
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ), // Original fontSize: 16
            ),
            const SizedBox(height: 8),
            ...comments.map((comment) {
              final date = DateFormat(
                'dd/MM/yyyy HH:mm',
              ).format(DateTime.parse(comment['timestamp']));
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    comment['bookTitle'],
                    // ONLY MODIFYING FONT SIZE
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ), // Original was default Text size (often 14)
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment['content'],
                        // ONLY MODIFYING FONT SIZE
                        style:
                            textTheme
                                .bodyMedium, // Original was default Text size (often 14-16)
                      ),
                      _buildStarRow(comment['rating']),
                      Text(
                        date,
                        // ONLY MODIFYING FONT SIZE
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ), // Original fontSize: 10
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
