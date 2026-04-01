import 'package:firebase_auth/firebase_auth.dart';
import 'package:sparkle/core/errors/app_errors.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<User> signUp({required String email, required String password}) async {
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return cred.user!;
    } on FirebaseAuthException catch (fErr) {
      throw AuthErrors(message: firebaseAuthErrorToMessage(fErr.code));
    } catch (err) {
      throw UnknownErrors();
    }
  }

  Future<User> signIn({required String email, required String password}) async {
    try {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return cred.user!;
    } on FirebaseException catch (fErr) {
      throw AuthErrors(message: firebaseAuthErrorToMessage(fErr.code));
    } catch (err) {
      throw UnknownErrors();
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
