// lib/domain/entities/user.dart

class User {
  final String id;
  final String name;
  final String email;
  final String pw;
  final String role;
  final DateTime createAt;

  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.pw,
      required this.role,
      required this.createAt});
}
