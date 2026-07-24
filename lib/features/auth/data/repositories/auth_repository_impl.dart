import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:smart_courier/core/error/failure.dart';
import 'package:smart_courier/core/logging/app_logger.dart';
import 'package:smart_courier/features/auth/data/constants/auth_error_messages.dart';
import 'package:smart_courier/features/auth/data/constants/auth_firestore_fields.dart';
import 'package:smart_courier/features/auth/data/mappers/firebase_exception_mapper.dart';
import 'package:smart_courier/features/auth/data/mappers/user_mapper.dart';
import 'package:smart_courier/features/auth/domain/entities/user.dart';
import 'package:smart_courier/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore;

  static const _logTag = 'AuthRepository';

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection(AuthFirestoreFields.usersCollection);

  @override
  Future<User> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    firebase_auth.UserCredential? credential;

    try {
      AppLogger.debug(
        'register → createUserWithEmailAndPassword',
        tag: _logTag,
      );
      credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const UnknownFailure();
      }

      AppLogger.debug(
        'register → Firestore set users/${firebaseUser.uid}',
        tag: _logTag,
      );
      await _usersCollection.doc(firebaseUser.uid).set({
        AuthFirestoreFields.name: name,
        AuthFirestoreFields.phone: phone,
        AuthFirestoreFields.role: UserRole.customer.name,
        AuthFirestoreFields.createdAt: FieldValue.serverTimestamp(),
      });

      AppLogger.debug(
        'register ← success uid=${firebaseUser.uid}',
        tag: _logTag,
      );
      return User(id: firebaseUser.uid, email: email, role: UserRole.customer);
    } on Failure catch (failure) {
      await _rollbackCreatedAuthUser(credential?.user);
      AppLogger.error('register ✕ ${failure.message}', tag: _logTag);
      rethrow;
    } on firebase_auth.FirebaseAuthException catch (error) {
      AppLogger.error(
        'register ✕ FirebaseAuth [${error.code}] ${error.message}',
        tag: _logTag,
        error: error,
      );
      throw FirebaseExceptionMapper.fromAuthException(error);
    } on FirebaseException catch (error) {
      await _rollbackCreatedAuthUser(credential?.user);
      AppLogger.error(
        'register ✕ Firestore [${error.code}] ${error.message}',
        tag: _logTag,
        error: error,
      );
      throw FirebaseExceptionMapper.fromFirebaseException(error);
    } catch (error, stackTrace) {
      await _rollbackCreatedAuthUser(credential?.user);
      AppLogger.error(
        'register ✕ unexpected error',
        tag: _logTag,
        error: error,
        stackTrace: stackTrace,
      );
      throw const UnknownFailure();
    }
  }

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      AppLogger.debug('login → signInWithEmailAndPassword', tag: _logTag);
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const UnknownFailure();
      }

      final user = await _fetchUserProfile(
        userId: firebaseUser.uid,
        email: firebaseUser.email ?? email,
      );
      AppLogger.debug('login ← success uid=${user.id}', tag: _logTag);
      return user;
    } on Failure catch (failure) {
      AppLogger.error('login ✕ ${failure.message}', tag: _logTag);
      rethrow;
    } on firebase_auth.FirebaseAuthException catch (error) {
      AppLogger.error(
        'login ✕ FirebaseAuth [${error.code}] ${error.message}',
        tag: _logTag,
        error: error,
      );
      throw FirebaseExceptionMapper.fromAuthException(error);
    } on FirebaseException catch (error) {
      AppLogger.error(
        'login ✕ Firestore [${error.code}] ${error.message}',
        tag: _logTag,
        error: error,
      );
      throw FirebaseExceptionMapper.fromFirebaseException(error);
    } catch (error, stackTrace) {
      AppLogger.error(
        'login ✕ unexpected error',
        tag: _logTag,
        error: error,
        stackTrace: stackTrace,
      );
      throw const UnknownFailure();
    }
  }

  @override
  Future<void> logout() async {
    try {
      AppLogger.debug('logout → signOut', tag: _logTag);
      await _firebaseAuth.signOut();
      AppLogger.debug('logout ← success', tag: _logTag);
    } on firebase_auth.FirebaseAuthException catch (error) {
      AppLogger.error(
        'logout ✕ FirebaseAuth [${error.code}] ${error.message}',
        tag: _logTag,
        error: error,
      );
      throw FirebaseExceptionMapper.fromAuthException(error);
    } catch (error, stackTrace) {
      AppLogger.error(
        'logout ✕ unexpected error',
        tag: _logTag,
        error: error,
        stackTrace: stackTrace,
      );
      throw const UnknownFailure();
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        AppLogger.debug('getCurrentUser ← no session', tag: _logTag);
        return null;
      }

      AppLogger.debug(
        'getCurrentUser → fetch profile uid=${firebaseUser.uid}',
        tag: _logTag,
      );
      final user = await _fetchUserProfile(
        userId: firebaseUser.uid,
        email: firebaseUser.email ?? '',
      );
      AppLogger.debug('getCurrentUser ← success uid=${user.id}', tag: _logTag);
      return user;
    } on Failure catch (failure) {
      AppLogger.error('getCurrentUser ✕ ${failure.message}', tag: _logTag);
      rethrow;
    } on firebase_auth.FirebaseAuthException catch (error) {
      AppLogger.error(
        'getCurrentUser ✕ FirebaseAuth [${error.code}] ${error.message}',
        tag: _logTag,
        error: error,
      );
      throw FirebaseExceptionMapper.fromAuthException(error);
    } on FirebaseException catch (error) {
      AppLogger.error(
        'getCurrentUser ✕ Firestore [${error.code}] ${error.message}',
        tag: _logTag,
        error: error,
      );
      throw FirebaseExceptionMapper.fromFirebaseException(error);
    } catch (error, stackTrace) {
      AppLogger.error(
        'getCurrentUser ✕ unexpected error',
        tag: _logTag,
        error: error,
        stackTrace: stackTrace,
      );
      throw const UnknownFailure();
    }
  }

  Future<User> _fetchUserProfile({
    required String userId,
    required String email,
  }) async {
    final snapshot = await _usersCollection.doc(userId).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      throw const UnknownFailure(AuthErrorMessages.profileNotFound);
    }

    return UserMapper.fromFirestore(id: userId, email: email, data: data);
  }

  Future<void> _rollbackCreatedAuthUser(
    firebase_auth.User? firebaseUser,
  ) async {
    if (firebaseUser == null) {
      return;
    }

    try {
      AppLogger.warning(
        'Rolling back auth user uid=${firebaseUser.uid}',
        tag: _logTag,
      );
      await firebaseUser.delete();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to roll back auth user uid=${firebaseUser.uid}',
        tag: _logTag,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
