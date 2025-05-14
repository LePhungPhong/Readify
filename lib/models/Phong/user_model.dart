class UserModel {
  final int? id;
  final String email;
  final String password;
  final String name;
  final String? avatarUrl;

  UserModel({
    this.id,
    required this.email,
    required this.password,
    required this.name,
    this.avatarUrl,
  });

  // Phương thức từ Map vào đối tượng UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      name: map['name'],
      avatarUrl: map['avatar_url'],
    );
  }

  // Phương thức chuyển đổi đối tượng UserModel thành Map để lưu vào database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'avatar_url': avatarUrl,
    };
  }
}
