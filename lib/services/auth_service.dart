import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //Firebase auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //function to handle user signup
  Future<String?> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      //create user in firebase auth with email and password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      //save additional user data in firestore
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "name": name.trim(),
        "email": email.trim(),
        "role": role, // role determines if user is admin or user
      });
      return null; //success
    } catch (e) {
      return e.toString(); // error
    }
  }

  // functions to handle user login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      //sign in user using firebase auth with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // fetching the user's role from firestore
      DocumentSnapshot userDoc =
          await _firestore
              .collection("users")
              .doc(userCredential.user!.uid)
              .get();

      return userDoc['role']; //return the role
    } catch (e) {
      return e.toString(); // error
    }
  }

  // user logout function
  signOut() async {
    _auth.signOut();
  }

  // NEW: Password reset function (added without modifying existing code)
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null; // success
    } catch (e) {
      return e.toString(); // error
    }
  }

  // NEW: Helper function to handle FirebaseAuth errors consistently
  String handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'Password is too weak';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      default:
        return e.message ?? 'An unknown error occurred';
    }
  }
}