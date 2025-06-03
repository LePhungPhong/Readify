class Comment {
  final String id;
  final String userName;
  final String content;
  final int rating;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.userName,
    required this.content,
    required this.rating,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'userName': userName,
    'content': content,
    'rating': rating,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Comment.fromJson(String id, Map<String, dynamic> json) => Comment(
    id: id,
    userName: json['userName'] ?? '',
    content: json['content'] ?? '',
    rating: json['rating'] ?? 0,
    timestamp: DateTime.parse(json['timestamp']),
  );
}
