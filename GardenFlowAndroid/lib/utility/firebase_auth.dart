import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import 'package:garden_flow/utility/toast.dart';

class Auth {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<void> signInWithEmailPassword({required String email, required String password}) async {
    await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword({required String email, required String password}) async {
    await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<bool> reauthenticateWithCredential(BuildContext context, User user, AuthCredential credential) async {
    try {
      await user.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'wrong-password':
          message = 'The password is incorrect. Please try again.';
          break;
        default:
          message = 'An unknown error occurred. Please try again.';
          break;
      }
      if (context.mounted) {
        Toast.show(context, message);
      }
      return false;
    } catch (e) {
      print('An error occurred: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}
