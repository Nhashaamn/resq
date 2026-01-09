import 'package:dartz/dartz.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/auth/domain/entities/user.dart' as domain;

abstract class AuthRepository {
  Future<Either<Failure, domain.User>> login(String email, String password);
  Future<Either<Failure, domain.User>> signup(String name, String email, String password);
  Future<Either<Failure, String>> sendPhoneOtp(String phoneNumber);
  Future<Either<Failure, domain.User>> verifyPhoneOtp(String verificationId, String otp);
  Future<Either<Failure, domain.User>> signInWithGoogle();
  Future<Either<Failure, domain.User?>> getCurrentUser();
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, bool>> checkEmailExists(String email);
  Future<Either<Failure, bool>> checkPhoneExists(String phoneNumber);
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email);
}

