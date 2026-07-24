class UserDto {
  const UserDto({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String name;
  final String phone;
  final String role;
  final DateTime createdAt;

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'phone': phone, 'role': role, 'createdAt': createdAt};
  }
}
