import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:resq/features/auth/data/models/user_model.dart';
import 'package:resq/features/auth/domain/entities/user.dart' as domain;
import 'package:resq/features/auth/domain/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FirebaseFirestore firestore;

  AuthRepositoryImpl(this.remoteDataSource, this.firestore);

  @override
  Future<Either<Failure, domain.User>> login(String email, String password) async {
    try {
      final credential = await remoteDataSource.login(email, password);
      return Right(credential.toDomain());
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(Failure.auth(_getErrorMessage(e.code)));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.User>> signup(String name, String email, String password) async {
    try {
      final credential = await remoteDataSource.signup(name, email, password);
      return Right(credential.toDomain());
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(Failure.auth(_getErrorMessage(e.code)));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.User?>> getCurrentUser() async {
    try {
      final firebaseUser = remoteDataSource.getCurrentUser();
      if (firebaseUser == null) {
        return const Right(null);
      }
      return Right(domain.User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName,
      ));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> sendPhoneOtp(String phoneNumber) async {
    try {
      final verificationId = await remoteDataSource.sendPhoneOtp(phoneNumber);
      return Right(verificationId);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(Failure.auth(_getErrorMessage(e.code)));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.User>> verifyPhoneOtp(String verificationId, String otp) async {
    try {
      final credential = await remoteDataSource.verifyPhoneOtp(verificationId, otp);
      final user = credential.user!;
      
      // Get phone number from user or from phoneNumber field
      final phoneNumber = user.phoneNumber;
      
      // Save phone number to Firestore
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        try {
          await remoteDataSource.saveUserPhoneNumber(user.uid, phoneNumber);
        } catch (e) {
          // Log error but don't fail the authentication
          print('Failed to save phone number: $e');
        }
      }
      
      // Also ensure user document exists in Firestore
      try {
        await firestore.collection('users').doc(user.uid).set(
          {
            'phoneNumber': phoneNumber ?? '',
            'email': user.email ?? '',
            'name': user.displayName ?? '',
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      } catch (e) {
        print('Failed to save user data: $e');
      }
      
      return Right(domain.User(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName,
      ));
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(Failure.auth(_getErrorMessage(e.code)));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.User>> signInWithGoogle() async {
    try {
      final credential = await remoteDataSource.signInWithGoogle();
      final user = credential.user;
      
      // Save user data to Firestore if it's a new user
      if (user != null) {
        try {
          await firestore.collection('users').doc(user.uid).set(
            {
              'email': user.email ?? '',
              'name': user.displayName ?? '',
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        } catch (e) {
          // Log error but don't fail the authentication
          print('Failed to save Google sign-in user data: $e');
        }
      }
      
      return Right(credential.toDomain());
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(Failure.auth(_getErrorMessage(e.code)));
    } catch (e) {
      return Left(Failure.auth(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkEmailExists(String email) async {
    try {
      final exists = await remoteDataSource.checkEmailExists(email);
      return Right(exists);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkPhoneExists(String phoneNumber) async {
    try {
      final exists = await remoteDataSource.checkPhoneExists(phoneNumber);
      return Right(exists);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'invalid-verification-code':
        return 'Invalid OTP code. Please check and try again';
      case 'invalid-verification-id':
        return 'Invalid verification ID. Please request a new code';
      case 'session-expired':
        return 'OTP session expired. Please request a new code';
      case 'code-expired':
        return 'The verification code has expired. Please request a new one';
      case 'quota-exceeded':
        return 'Too many requests. Please try again later';
      case 'invalid-phone-number':
        return 'Invalid phone number format';
      case 'missing-verification-code':
        return 'Verification code is required';
      case 'missing-verification-id':
        return 'Verification ID is required';
      case 'phone-number-already-exists':
        return 'This phone number is already registered';
      default:
        return 'Authentication failed: $code. Please try again';
    }
  }
}

