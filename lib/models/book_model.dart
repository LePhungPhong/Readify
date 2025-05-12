class Author {
  final String name;
  final int? birthYear;
  final int? deathYear;

  Author({required this.name, this.birthYear, this.deathYear});

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      name: json['name'],
      birthYear: json['birth_year'],
      deathYear: json['death_year'],
    );
  }
}

class Book {
  final int id;
  final String title;
  final List<Author> authors;
  final String? coverUrl;
  final String? contentUrl;
  final List<String> summaries;
  final List<String> subjects;
  final List<String> bookshelves;
  final List<String> languages;
  final bool isCopyright;
  final String mediaType;
  final int downloadCount;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    this.coverUrl,
    this.contentUrl,
    this.summaries = const [],
    required this.subjects, // Chắc chắn tham số này được truyền
    required this.bookshelves,
    required this.languages,
    required this.isCopyright,
    required this.mediaType,
    required this.downloadCount,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      authors:
          (json['authors'] as List)
              .map((author) => Author.fromJson(author))
              .toList(),
      coverUrl: json['formats']['image/jpeg'],
      contentUrl: json['formats']['text/html'] ?? '',
      summaries: List<String>.from(json['summaries'] ?? []),
      subjects: List<String>.from(
        json['subjects'] ?? [],
      ), // Đảm bảo subjects có giá trị
      bookshelves: List<String>.from(json['bookshelves'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      isCopyright: json['copyright'] ?? false,
      mediaType: json['media_type'] ?? '',
      downloadCount: json['download_count'] ?? 0,
    );
  }
}

class User {
  final int id;
  final String email;
  final String? password;
  final String? name;
  final String? avatarUrl;
  final String? createdAt;

  User({
    required this.id,
    required this.email,
    this.password,
    this.name,
    this.avatarUrl,
    this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      name: map['name'],
      avatarUrl: map['avatar_url'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'avatar_url': avatarUrl,
      'created_at': createdAt,
    };
  }
}
