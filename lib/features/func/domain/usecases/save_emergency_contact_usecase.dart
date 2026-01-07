import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/repositories/emergency_contact_repository.dart';

@injectable
class AddEmergencyContactUseCase {
  final EmergencyContactRepository repository;

  AddEmergencyContactUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String userId, String name, String phoneNumber) async {
    if (name.trim().isEmpty) {
      return const Left(Failure.validation('Name is required'));
    }
    if (phoneNumber.trim().isEmpty) {
      return const Left(Failure.validation('Phone number is required'));
    }
    if (phoneNumber.trim().length < 10) {
      return const Left(Failure.validation('Please enter a valid phone number'));
    }
    
    // Check if we already have 5 contacts
    final contactsResult = await repository.getEmergencyContacts(userId);
    return contactsResult.fold(
      (failure) => Left(failure),
      (contacts) {
        if (contacts.length >= 5) {
          return const Left(Failure.validation('Maximum 5 emergency contacts allowed'));
        }
        return repository.addEmergencyContact(userId, name.trim(), phoneNumber.trim());
      },
    );
  }
}

