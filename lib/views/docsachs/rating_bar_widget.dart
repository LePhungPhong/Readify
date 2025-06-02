import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:readify/models/Phong/user_model.dart';

class RatingBarWidget extends StatefulWidget {
  final int bookId;
  final UserModel user;

  const RatingBarWidget({super.key, required this.bookId, required this.user});

  @override
  State<RatingBarWidget> createState() => _RatingBarWidgetState();
}

class _RatingBarWidgetState extends State<RatingBarWidget> {
  final _commentController = TextEditingController();
  int _rating = 0;
  String? _editingCommentId;

  Future<void> _submitComment() async {
    if (_rating == 0 || _commentController.text.trim().isEmpty) return;

    final commentData = {
      'userId': widget.user.id,
      'userName': widget.user.name,
      'userAvatar': widget.user.avatarUrl,
      'content': _commentController.text.trim(),
      'rating': _rating,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final commentsRef = FirebaseFirestore.instance
        .collection('books')
        .doc(widget.bookId.toString())
        .collection('comments');

    if (_editingCommentId != null) {
      await commentsRef.doc(_editingCommentId).update(commentData);
    } else {
      await commentsRef.add(commentData);
    }

    _commentController.clear();
    setState(() {
      _rating = 0;
      _editingCommentId = null;
    });
  }

  Future<void> _deleteComment(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              "Xoá bình luận",
              style:
                  Theme.of(context).textTheme.titleLarge, // Sử dụng titleLarge
            ),
            content: Text(
              "Bạn có chắc muốn xoá bình luận này?",
              style:
                  Theme.of(context).textTheme.bodyMedium, // Sử dụng bodyMedium
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "Huỷ",
                  style:
                      Theme.of(
                        context,
                      ).textTheme.labelLarge, // Sử dụng labelLarge
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  "Xoá",
                  style:
                      Theme.of(
                        context,
                      ).textTheme.labelLarge, // Sử dụng labelLarge
                ),
              ),
            ],
          ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.bookId.toString())
          .collection('comments')
          .doc(docId)
          .delete();
    }
  }

  void _editComment(Map<String, dynamic> data, String docId) {
    setState(() {
      _commentController.text = data['content'];
      _rating = data['rating'];
      _editingCommentId = docId;
    });
  }

  Widget _buildStarRow(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          Icons.star,
          size: 16, // Kích thước icon có thể giữ nguyên hoặc được quản lý riêng
          color: index < rating ? Colors.orange : Colors.grey,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final commentsRef = FirebaseFirestore.instance
        .collection('books')
        .doc(widget.bookId.toString())
        .collection('comments');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // STAR RATING SELECTOR
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                Icons.star,
                color: index < _rating ? Colors.orange : Colors.grey,
              ),
              onPressed: () => setState(() => _rating = index + 1),
            );
          }),
        ),
        TextField(
          controller: _commentController,
          decoration: InputDecoration(
            hintText: 'Nhập bình luận của bạn...',
            border: const OutlineInputBorder(),
            hintStyle:
                Theme.of(
                  context,
                ).textTheme.bodyMedium, // Sử dụng bodyMedium cho hintText
          ),
          style:
              Theme.of(
                context,
              ).textTheme.bodyMedium, // Sử dụng bodyMedium cho text input
          maxLines: 2,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _submitComment,
          child: Text(
            _editingCommentId != null ? "Cập nhật" : "Gửi đánh giá",
            style:
                Theme.of(
                  context,
                ).textTheme.bodyLarge, // Sử dụng bodyLarge cho nút
          ),
        ),
        const SizedBox(height: 20),

        // COMMENT LIST + AVERAGE
        StreamBuilder<QuerySnapshot>(
          stream:
              commentsRef.orderBy('timestamp', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return Text(
                "Chưa có đánh giá nào.",
                style:
                    Theme.of(
                      context,
                    ).textTheme.bodyMedium, // Sử dụng bodyMedium
              );
            }

            double avgRating = 0;
            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              avgRating += (data['rating'] ?? 0).toDouble();
            }
            avgRating = avgRating / docs.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "⭐ ${avgRating.toStringAsFixed(1)} (${docs.length} đánh giá)",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ), // Sử dụng titleMedium (mặc định 16)
                ),
                const SizedBox(height: 10),
                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final date = DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(DateTime.parse(data['timestamp']));
                  final isOwner = data['userId'] == widget.user.id;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading:
                          data['userAvatar'] != null
                              ? CircleAvatar(
                                backgroundImage: NetworkImage(
                                  data['userAvatar'],
                                ),
                              )
                              : const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(
                        data['userName'] ?? 'Ẩn danh',
                        style:
                            Theme.of(context)
                                .textTheme
                                .titleSmall, // Sử dụng titleSmall (mặc định 14)
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['content'],
                            style:
                                Theme.of(context)
                                    .textTheme
                                    .bodyMedium, // Sử dụng bodyMedium (mặc định 14)
                          ),
                          const SizedBox(height: 4),
                          _buildStarRow(data['rating']),
                          Text(
                            date,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ), // Sử dụng bodySmall (mặc định 12)
                          ),
                        ],
                      ),
                      trailing:
                          isOwner
                              ? PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit')
                                    _editComment(data, doc.id);
                                  if (value == 'delete') _deleteComment(doc.id);
                                },
                                itemBuilder:
                                    (_) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text(
                                          "Sửa",
                                          style:
                                              Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium, // Sử dụng bodyMedium
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text(
                                          "Xoá",
                                          style:
                                              Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium, // Sử dụng bodyMedium
                                        ),
                                      ),
                                    ],
                              )
                              : null,
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }
}
