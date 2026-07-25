import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:smart_courier/core/error/failure.dart';
import 'package:smart_courier/core/logging/app_logger.dart';
import 'package:smart_courier/core/utils/result.dart';
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
  static const _profileFetchTimeout = Duration(seconds: 15);

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection(AuthFirestoreFields.usersCollection);

  @override
  Future<Result<User>> register({
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
        return const ResultFailure(UnknownFailure());
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

      AppLogger.debug('register → sendEmailVerification', tag: _logTag);
      await firebaseUser.sendEmailVerification();

      AppLogger.debug(
        'register ← success uid=${firebaseUser.uid}',
        tag: _logTag,
      );
      return Success(
        User(
          id: firebaseUser.uid,
          email: email,
          role: UserRole.customer,
          emailVerified: firebaseUser.emailVerified,
        ),
      );
    } on Failure catch (failure) {
      await _rollbackCreatedAuthUser(credential?.user);
      AppLogger.error('register ✕ ${failure.message}', tag: _logTag);
      return ResultFailure(failure);
    } on firebase_auth.FirebaseAuthException catch (error) {
      AppLogger.error(
        'register ✕ FirebaseAuth [${error.code}] ${error.message}',
        tag: _logTag,
        error: error,
      );
      return ResultFailure(
        FirebaseExceptionMapper.fromAuthException(
          error,
          context: AuthExceptionContext.register,
        ),
      );
    } on FirebaseException catch (error) {
      await _rollbackCreatedAuthUser(credential?.user);
      AppLogger.error(
        'register ✕ Firestore [${error.code}] ${error.message}',
        tag: _logTag,
        error: error,
      );
      return ResultFailure(
        FirebaseExceptionMapper.fromFirebaseException(error),
      );
    } catch (error, stackTrace) {
      await _rollbackCreatedAuthUser(credential?.user);
      AppLogger.error(
        'register ✕ unexpected error',
        tag: _logTag,
        error: error,
        stackTrace: stackTrace,
      );
      return const ResultFailure(UnknownFailure());
    }
  }

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.debug('login → signInWithEmailAndPassword', tag: _logTag);
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return const ResultFailure(UnknownFailure());
      }

      final user = await _fetchUserProfile(firebaseUser: firebaseUser);
      AppLogger.debug('login ← success uid=${user.id}', tag: _logTag);
      return Success(user);
    } on Failure catch (failure) {
      AppLogger.error('login ✕ ${failure.message}', tag: _logTag);
      return ResultFailure(failure);
    } on firebase_auth.FirebaseAuthException catch (error) {
      AppLogger.error(
        'login ✕ FirebaseAuth [${error.code}] ${error.message}',
        tag: _logTag,
        error: error,
      );
      return ResultFailure(
        FirebaseExceptionMapper.fromAuthException(
          error,
          context: AuthExceptionContext.login,
        ),
      );
    } on FirebaseException catch (error) {
      await _clearAuthSessionAfterProfileFailure();
      AppLogger.error(
        'login ✕ Firestore [${error.code}] ${error.message}',
        tag: _logTag,
        error: error,
      );
      return ResultFailure(
        FirebaseExceptionMapper.fromFirebaseException(error),
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'login ✕ unexpected error',
        tag: _logTag,
        error: error,
        stackTrace: stackTrace,
      );
      return const ResultFailure(UnknownFailure());
    }
  }

  @override
  Future<Result<Unit>> logout() async {
    try {
      AppLogger.debug('logout → signOut', tag: _logTag);
      await _firebaseAuth.signOut();
      AppLogger.debug('logout ← success', tag: _logTag);
      return const Success(Unit.value);
    } on firebase_auth.FirebaseAuthException catch (error) {
      AppLogger.error(
        'logout ✕ FirebaseAuth [${error.code}] ${error.message}',
        tag: _logTag,
        error: error,
      );
      return ResultFailure(
        FirebaseExceptionMapper.fromAuthException(
          error,
          context: AuthExceptionContext.login,
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'logout ✕ unexpected error',
        tag: _logTag,
        error: error,
        stackTrace: stackTrace,
      );
      return const ResultFailure(UnknownFailure());
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        AppLogger.debug('getCurrentUser ← no session', tag: _logTag);
        return const Success(null);
      }

      AppLogger.debug(
        'getCurrentUser → fetch profile uid=${firebaseUser.uid}',
        tag: _logTag,
      );
      final user = await _fetchUserProfile(firebaseUser: firebaseUser);
      AppLogger.debug('getCurrentUser ← success uid=${user.id}', tag: _logTag);
      return Success(user);
    } on Failure catch (failure) {
      if (failure.message == AuthErrorMessages.profileNotFound) {
        await _clearAuthSessionAfterProfileFailure();
        AppLogger.warning(
          'getCurrentUser ← profile missing, session cleared',
          tag: _logTag,
        );
        return const Success(null);
      }
      AppLogger.error('getCurrentUser ✕ ${failure.message}', tag: _logTag);
      return ResultFailure(failure);
    } on TimeoutException catch (error, stackTrace) {
      await _clearAuthSessionAfterProfileFailure();
      AppLogger.error(
        'getCurrentUser ✕ profile fetch timeout',
        tag: _logTag,
        error: error,
        stackTrace: stackTrace,
      );
      return const Success(null);
    } on firebase_auth.FirebaseAuthException catch (error) {
      AppLogger.error(
        'getCurrentUser ✕ FirebaseAuth [${error.code}] ${error.message}',
        tag: _logTag,
        error: error,
      );
      return ResultFailure(
        FirebaseExceptionMapper.fromAuthException(
          error,
          context: AuthExceptionContext.login,
        ),
      );
    } on FirebaseException catch (error) {
      final failure = FirebaseExceptionMapper.fromFirebaseException(error);
      if (failure is NetworkFailure) {
        await _clearAuthSessionAfterProfileFailure();
        AppLogger.warning(
          'getCurrentUser ← offline, session cleared',
          tag: _logTag,
        );
        return const Success(null);
      }

      AppLogger.error(
        'getCurrentUser ✕ Firestore [${error.code}] ${error.message}',
        tag: _logTag,
        error: error,
      );
      return ResultFailure(failure);
    } catch (error, stackTrace) {
      AppLogger.error(
        'getCurrentUser ✕ unexpected error',
        tag: _logTag,
        error: error,
        stackTrace: stackTrace,
      );
      return const ResultFailure(UnknownFailure());
    }
  }

  @override
  Future<Result<Unit>> sendPasswordResetEmail({required String email}) async {
    try {
      AppLogger.debug('sendPasswordResetEmail → $email', tag: _logTag);
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      AppLogger.debug('sendPasswordResetEmail ← success', tag: _logTag);
      return const Success(Unit.value);
    } on firebase_auth.FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') {
        AppLogger.debug(
          'sendPasswordResetEmail ← generic success (no enumeration)',
          tag: _logTag,
        );
        return const Success(Unit.value);
      }

      AppLogger.error(
        'sendPasswordResetEmail ✕ FirebaseAuth [${error.code}]',
        tag: _logTag,
        error: error,
      );
      return ResultFailure(
        FirebaseExceptionMapper.fromAuthException(
          error,
          context: AuthExceptionContext.passwordReset,
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'sendPasswordResetEmail ✕ unexpected error',
        tag: _logTag,
        error: error,
        stackTrace: stackTrace,
      );
      return const ResultFailure(UnknownFailure());
    }
  }

  @override
  Future<Result<Unit>> sendEmailVerification() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return const ResultFailure(AuthFailure());
      }

      AppLogger.debug(
        'sendEmailVerification → uid=${firebaseUser.uid}',
        tag: _logTag,
      );
      await firebaseUser.sendEmailVerification();
      AppLogger.debug('sendEmailVerification ← success', tag: _logTag);
      return const Success(Unit.value);
    } on firebase_auth.FirebaseAuthException catch (error) {
      AppLogger.error(
        'sendEmailVerification ✕ FirebaseAuth [${error.code}]',
        tag: _logTag,
        error: error,
      );
      return ResultFailure(
        FirebaseExceptionMapper.fromAuthException(
          error,
          context: AuthExceptionContext.login,
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'sendEmailVerification ✕ unexpected error',
        tag: _logTag,
        error: error,
        stackTrace: stackTrace,
      );
      return const ResultFailure(UnknownFailure());
    }
  }

  Future<User> _fetchUserProfile({
    required firebase_auth.User firebaseUser,
  }) async {
    await firebaseUser.reload().timeout(_profileFetchTimeout);
    final refreshedUser = _firebaseAuth.currentUser ?? firebaseUser;

    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        return await _readUserProfile(
          userId: refreshedUser.uid,
          email: refreshedUser.email ?? '',
          emailVerified: refreshedUser.emailVerified,
        );
      } on FirebaseException catch (error) {
        final isOffline = error.code == 'unavailable';
        if (isOffline && attempt == 0) {
          AppLogger.warning(
            'Firestore offline, retrying after enableNetwork',
            tag: _logTag,
          );
          await _firestore.enableNetwork();
          continue;
        }
        rethrow;
      }
    }

    throw const UnknownFailure();
  }

  Future<User> _readUserProfile({
    required String userId,
    required String email,
    required bool emailVerified,
  }) async {
    final snapshot = await _usersCollection
        .doc(userId)
        .get()
        .timeout(_profileFetchTimeout);
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      throw const UnknownFailure(AuthErrorMessages.profileNotFound);
    }

    return UserMapper.fromFirestore(
      id: userId,
      email: email,
      data: data,
      emailVerified: emailVerified,
    );
  }

  Future<void> _clearAuthSessionAfterProfileFailure() async {
    try {
      await _firebaseAuth.signOut();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to clear auth session after profile error',
        tag: _logTag,
        error: error,
        stackTrace: stackTrace,
      );
    }
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
