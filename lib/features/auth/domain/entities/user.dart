import 'package:equatable/equatable.dart';

enum UserRole { customer, courier, admin }

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.role,
    this.emailVerified = false,
  });

  final String id;
  final String email;
  final UserRole role;
  final bool emailVerified;

  User copyWith({
    String? id,
    String? email,
    UserRole? role,
    bool? emailVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  @override
  List<Object> get props => [id, email, role, emailVerified];
}
