import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

abstract class AuthRemoteDataSource {
  Future<firebase_auth.UserCredential> login(String email, String password);
  Future<firebase_auth.UserCredential> signup(String name, String email, String password);
  Future<String> sendPhoneOtp(String phoneNumber);
  Future<firebase_auth.UserCredential> verifyPhoneOtp(String verificationId, String otp);
  Future<firebase_auth.UserCredential> signInWithGoogle();
  firebase_auth.User? getCurrentUser();
  Future<void> logout();
  Future<bool> checkEmailExists(String email);
  Future<bool> checkPhoneExists(String phoneNumber);
  Future<void> saveUserPhoneNumber(String userId, String phoneNumber);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl(this._firebaseAuth, this._googleSignIn, this._firestore);

  @override
  Future<firebase_auth.UserCredential> login(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException {
      // Re-throw Firebase Auth exceptions
      rethrow;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  @override
  Future<firebase_auth.UserCredential> signup(String name, String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        // Save user email to Firestore
        try {
          await _firestore.collection('users').doc(user.uid).set(
            {
              'email': email,
              'name': name,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        } catch (e) {
          // Log error but don't fail signup
          print('Failed to save user data to Firestore: $e');
        }
      }
      return credential;
    } on firebase_auth.FirebaseAuthException {
      // Re-throw Firebase Auth exceptions
      rethrow;
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  @override
  Future<String> sendPhoneOtp(String phoneNumber) async {
    final completer = Completer<String>();
    
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) {
          if (!completer.isCompleted) {
            completer.complete(credential.verificationId ?? '');
          }
        },
        verificationFailed: (error) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        },
        codeSent: (verificationId, _) {
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
        codeAutoRetrievalTimeout: (verificationId) {
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    }
    
    return completer.future;
  }

  @override
  Future<firebase_auth.UserCredential> verifyPhoneOtp(String verificationId, String otp) async {
    try {
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      return await _firebaseAuth.signInWithCredential(credential);
    } on firebase_auth.FirebaseAuthException {
      // Re-throw Firebase Auth exceptions
      rethrow;
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  @override
  Future<firebase_auth.UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _firebaseAuth.signInWithCredential(credential);
    } on firebase_auth.FirebaseAuthException {
      // Re-throw Firebase Auth exceptions
      rethrow;
    } catch (e) {
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }

  @override
  firebase_auth.User? getCurrentUser() => _firebaseAuth.currentUser;

  @override
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<bool> checkEmailExists(String email) async {
    try {
      // Firebase Auth automatically prevents duplicate emails during signup
      // This method is kept for consistency but Firebase will handle the check
      // We can query Firestore to check if email exists in user documents
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      // If error occurs, assume email doesn't exist to allow registration
      return false;
    }
  }

  @override
  Future<bool> checkPhoneExists(String phoneNumber) async {
    try {
      // Query Firestore to check if phone number is already registered
      final querySnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      // If error occurs, assume phone doesn't exist to allow registration
      return false;
    }
  }

  @override
  Future<void> saveUserPhoneNumber(String userId, String phoneNumber) async {
    try {
      await _firestore.collection('users').doc(userId).set(
        {
          'phoneNumber': phoneNumber,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to save phone number: $e');
    }
  }
}

