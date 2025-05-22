import 'dart:convert';

class Author {
  final String name;
  final int? birthYear;
  final int? deathYear;

  Author({required this.name, this.birthYear, this.deathYear});

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      name: json['name'] ?? '',
      birthYear: json['birth_year'] != null ? json['birth_year'] as int : null,
      deathYear: json['death_year'] != null ? json['death_year'] as int : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'birth_year': birthYear, 'death_year': deathYear};
  }
}

class Book {
  final int id;
  final String title;
  final List<String> authors;
  final String? coverUrl;
  final String? contentUrl;
  final List<String> summaries;
  final List<String> subjects;
  final List<String> bookshelves;
  final List<String> languages;
  final bool isCopyright;
  final String mediaType;
  final int downloadCount;
  final String? lastReadCfi;
  final String? filePath;
  final List<String> types;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    this.coverUrl,
    this.contentUrl,
    this.summaries = const [],
    this.subjects = const [],
    this.bookshelves = const [],
    this.languages = const [],
    required this.isCopyright,
    required this.mediaType,
    required this.downloadCount,
    this.lastReadCfi,
    this.filePath,
    this.types = const [],
  });

  // Chuyển từ Map JSON (ví dụ từ API) sang Book (dùng khi mới lấy từ API)
  factory Book.fromApiJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic value) {
      if (value == null) return [];
      if (value is String) {
        return value.split(',').map((e) => e.trim()).toList();
      }
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    // Lấy ảnh cover an toàn từ formats
    String? coverUrl;
    if (json['formats'] != null && json['formats'] is Map) {
      var formats = json['formats'] as Map;
      if (formats['image/jpeg'] != null && formats['image/jpeg'] is String) {
        coverUrl = formats['image/jpeg'];
      }
    }

    // Lấy contentUrl định dạng epub
    String? contentUrl;
    if (json['formats'] != null && json['formats'] is Map) {
      var formats = json['formats'] as Map;
      if (formats['application/epub+zip'] != null &&
          formats['application/epub+zip'] is String) {
        contentUrl = formats['application/epub+zip'];
      }
    }

    List<String> summaries = [];
    if (json['summaries'] != null) {
      if (json['summaries'] is String) {
        summaries = [json['summaries']];
      } else if (json['summaries'] is List) {
        summaries =
            (json['summaries'] as List).map((e) => e.toString()).toList();
      }
    }

    List<String> authors = [];
    if (json['authors'] != null && json['authors'] is List) {
      authors =
          (json['authors'] as List).map((authorJson) {
            if (authorJson is Map<String, dynamic> &&
                authorJson['name'] != null) {
              return authorJson['name'].toString();
            }
            // Nếu không phải Map hoặc không có name thì convert thành string
            return authorJson.toString();
          }).toList();
    } else if (json['authors'] is String) {
      // Nếu authors là chuỗi, tách thành list theo dấu phẩy
      authors =
          (json['authors'] as String).split(',').map((e) => e.trim()).toList();
    }

    return Book(
      id: json['id'],
      title: json['title'] ?? '',
      authors: authors,
      coverUrl: coverUrl,
      contentUrl: contentUrl,
      summaries: summaries,
      subjects: parseList(json['subjects']),
      bookshelves: parseList(json['bookshelves']),
      languages: parseList(json['languages']),
      isCopyright: json['copyright'] ?? false,
      mediaType: json['media_type'] ?? '',
      downloadCount: json['download_count'] ?? 0,
      types: parseList(json['types']),
      lastReadCfi: null,
      filePath: null,
    );
  }

  // Chuyển từ Map lấy từ SQLite DB (các trường list đã được encode thành JSON string)
  factory Book.fromDbJson(Map<String, Object?> json) {
    List<String> parseListFromJsonString(String? jsonString) {
      if (jsonString == null || jsonString.isEmpty) return [];
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
      return [];
    }

    return Book(
      id: json['id'] as int,
      title: json['title'] as String,
      authors: parseListFromJsonString(json['authors'] as String?),
      coverUrl: json['coverUrl'] as String?,
      contentUrl: json['contentUrl'] as String?,
      summaries: parseListFromJsonString(json['summaries'] as String?),
      subjects: parseListFromJsonString(json['subjects'] as String?),
      bookshelves: parseListFromJsonString(json['bookshelves'] as String?),
      languages: parseListFromJsonString(json['languages'] as String?),
      isCopyright: (json['isCopyright'] as int) == 1,
      mediaType: json['mediaType'] as String,
      downloadCount: json['downloadCount'] as int,
      lastReadCfi: json['lastReadCfi'] as String?,
      filePath: json['filePath'] as String?,
      types: parseListFromJsonString(json['types'] as String?),
    );
  }

  // Chuyển Book thành Map để lưu vào SQLite DB
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'authors': jsonEncode(authors),
      'types': jsonEncode(types),
      'coverUrl': coverUrl,
      'contentUrl': contentUrl,
      'subjects': jsonEncode(subjects),
      'summaries': jsonEncode(summaries),
      'bookshelves': jsonEncode(bookshelves),
      'languages': jsonEncode(languages),
      'isCopyright': isCopyright ? 1 : 0,
      'mediaType': mediaType,
      'downloadCount': downloadCount,
      'lastReadCfi': lastReadCfi,
      'filePath': filePath ?? '',
    };
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
