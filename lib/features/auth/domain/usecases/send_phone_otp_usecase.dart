import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/auth/domain/repositories/auth_repository.dart';

@injectable
class SendPhoneOtpUseCase {
  final AuthRepository repository;

  SendPhoneOtpUseCase(this.repository);

  Future<Either<Failure, String>> call(String phoneNumber, {bool isSignup = true}) async {
    if (phoneNumber.isEmpty) {
      return const Left(Failure.validation('Phone number is required'));
    }
    // Basic phone validation (should start with + and have digits)
    if (!phoneNumber.startsWith('+') || phoneNumber.length < 10) {
      return const Left(Failure.validation('Please enter a valid phone number with country code'));
    }
    
    // Check if phone number already exists (only for signup, not login)
    if (isSignup) {
      final phoneCheck = await repository.checkPhoneExists(phoneNumber);
      return phoneCheck.fold(
        (failure) => Left(failure),
        (exists) async {
          if (exists) {
            return const Left(Failure.validation('This phone number is already registered'));
          }
          return await repository.sendPhoneOtp(phoneNumber);
        },
      );
    }
    
    return await repository.sendPhoneOtp(phoneNumber);
  }
}

