import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/auth/domain/entities/user.dart' as domain;
import 'package:resq/features/auth/domain/repositories/auth_repository.dart';

@injectable
class VerifyPhoneOtpUseCase {
  final AuthRepository repository;

  VerifyPhoneOtpUseCase(this.repository);

  Future<Either<Failure, domain.User>> call(String verificationId, String otp) async {
    if (verificationId.isEmpty || otp.isEmpty) {
      return const Left(Failure.validation('Verification ID and OTP are required'));
    }
    if (otp.length != 6) {
      return const Left(Failure.validation('OTP must be 6 digits'));
    }
    return await repository.verifyPhoneOtp(verificationId, otp);
  }
}

