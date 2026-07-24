import 'package:equatable/equatable.dart';

enum UserRole { customer, courier, admin }

class User extends Equatable {
  const User({required this.id, required this.email, required this.role});

  final String id;
  final String email;
  final UserRole role;

  @override
  List<Object> get props => [id, email, role];
}
