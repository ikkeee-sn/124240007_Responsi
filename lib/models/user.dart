class User {
  final String username;
  final String password;
  final String fullName;

  User({
    required this.username,
    required this.password,
    required this.fullName,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'fullName': fullName,
    };
  }

  factory User.fromMap(Map<dynamic, dynamic> map) {
    return User(
      username: map['username']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      fullName: map['fullName']?.toString() ?? '',
    );
  }
}
