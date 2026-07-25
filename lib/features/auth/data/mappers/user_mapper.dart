import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_courier/core/error/failure.dart';
import 'package:smart_courier/features/auth/data/constants/auth_firestore_fields.dart';
import 'package:smart_courier/features/auth/data/models/user_dto.dart';
import 'package:smart_courier/features/auth/domain/entities/user.dart';

abstract final class UserMapper {
  static User fromFirestore({
    required String id,
    required String email,
    required Map<String, dynamic> data,
    bool emailVerified = false,
  }) {
    final roleValue = data[AuthFirestoreFields.role] as String?;
    final role = _parseRole(roleValue);

    return User(id: id, email: email, role: role, emailVerified: emailVerified);
  }

  static UserDto toDto({
    required String id,
    required String email,
    required Map<String, dynamic> data,
  }) {
    final createdAtRaw = data[AuthFirestoreFields.createdAt];
    final createdAt = _parseCreatedAt(createdAtRaw);

    return UserDto(
      id: id,
      email: email,
      name: data[AuthFirestoreFields.name] as String? ?? '',
      phone: data[AuthFirestoreFields.phone] as String? ?? '',
      role: data[AuthFirestoreFields.role] as String? ?? UserRole.customer.name,
      createdAt: createdAt,
    );
  }

  static UserRole _parseRole(String? roleValue) {
    return switch (roleValue) {
      'courier' => UserRole.courier,
      'admin' => UserRole.admin,
      'customer' => UserRole.customer,
      _ => throw const UnknownFailure('Unsupported user role'),
    };
  }

  static DateTime _parseCreatedAt(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }
}
