import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:smart_courier/core/error/failure.dart';
import 'package:smart_courier/features/auth/data/constants/auth_error_messages.dart';
import 'package:smart_courier/features/auth/data/constants/auth_firestore_fields.dart';
import 'package:smart_courier/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_courier/features/auth/domain/entities/user.dart';

void main() {
  const email = 'user@example.com';
  const password = 'password';
  const name = 'Test User';
  const phone = '+10000000000';

  group('register', () {
    test('creates auth user and customer profile in Firestore', () async {
      final auth = MockFirebaseAuth();
      final firestore = FakeFirebaseFirestore();
      final repository = AuthRepositoryImpl(
        firebaseAuth: auth,
        firestore: firestore,
      );

      final user = await repository.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      expect(user.email, email);
      expect(user.role, UserRole.customer);

      final snapshot = await firestore
          .collection(AuthFirestoreFields.usersCollection)
          .doc(user.id)
          .get();
      final data = snapshot.data();
      expect(data?[AuthFirestoreFields.name], name);
      expect(data?[AuthFirestoreFields.phone], phone);
      expect(data?[AuthFirestoreFields.role], 'customer');
    });

    test('maps email-already-in-use to ValidationFailure', () async {
      final auth = MockFirebaseAuth();
      whenCalling(
        Invocation.method(#createUserWithEmailAndPassword, null, {
          #email: email,
          #password: password,
        }),
      ).on(auth).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
      final repository = AuthRepositoryImpl(
        firebaseAuth: auth,
        firestore: FakeFirebaseFirestore(),
      );

      expect(
        () => repository.register(
          email: email,
          password: password,
          name: name,
          phone: phone,
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (failure) => failure.message,
            'message',
            AuthErrorMessages.emailAlreadyInUse,
          ),
        ),
      );
    });
  });

  group('login', () {
    test('returns user with role loaded from Firestore', () async {
      const userId = 'user-id';
      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: userId, email: email),
      );
      final firestore = FakeFirebaseFirestore();
      await firestore
          .collection(AuthFirestoreFields.usersCollection)
          .doc(userId)
          .set({
            AuthFirestoreFields.name: name,
            AuthFirestoreFields.phone: phone,
            AuthFirestoreFields.role: 'courier',
            AuthFirestoreFields.createdAt: Timestamp.now(),
          });
      final repository = AuthRepositoryImpl(
        firebaseAuth: auth,
        firestore: firestore,
      );

      final user = await repository.login(email: email, password: password);

      expect(user.id, userId);
      expect(user.role, UserRole.courier);
    });

    test('maps invalid credentials to AuthFailure', () async {
      final auth = MockFirebaseAuth();
      whenCalling(
        Invocation.method(#signInWithEmailAndPassword, null, {
          #email: email,
          #password: 'bad-password',
        }),
      ).on(auth).thenThrow(FirebaseAuthException(code: 'wrong-password'));
      final repository = AuthRepositoryImpl(
        firebaseAuth: auth,
        firestore: FakeFirebaseFirestore(),
      );

      expect(
        () => repository.login(email: email, password: 'bad-password'),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.message,
            'message',
            AuthErrorMessages.incorrectCredentials,
          ),
        ),
      );
    });
  });

  group('getCurrentUser', () {
    test('returns null when Firebase session is absent', () async {
      final repository = AuthRepositoryImpl(
        firebaseAuth: MockFirebaseAuth(signedIn: false),
        firestore: FakeFirebaseFirestore(),
      );

      final user = await repository.getCurrentUser();

      expect(user, isNull);
    });

    test('returns persisted user profile for active session', () async {
      const userId = 'active-user';
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: userId, email: email),
      );
      final firestore = FakeFirebaseFirestore();
      await firestore
          .collection(AuthFirestoreFields.usersCollection)
          .doc(userId)
          .set({
            AuthFirestoreFields.name: name,
            AuthFirestoreFields.phone: phone,
            AuthFirestoreFields.role: 'admin',
            AuthFirestoreFields.createdAt: Timestamp.now(),
          });
      final repository = AuthRepositoryImpl(
        firebaseAuth: auth,
        firestore: firestore,
      );

      final user = await repository.getCurrentUser();

      expect(user?.role, UserRole.admin);
      expect(user?.email, email);
    });
  });

  group('logout', () {
    test('clears the Firebase auth session', () async {
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user-id', email: email),
      );
      final repository = AuthRepositoryImpl(
        firebaseAuth: auth,
        firestore: FakeFirebaseFirestore(),
      );

      await repository.logout();

      expect(auth.currentUser, isNull);
    });
  });
}
