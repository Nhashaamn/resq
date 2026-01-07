import 'package:injectable/injectable.dart';
import 'package:resq/features/func/domain/usecases/get_emergency_number_usecase.dart';

abstract class EmergencyNumberService {
  Future<String?> getEmergencyNumber(String userId);
}

@LazySingleton(as: EmergencyNumberService)
class EmergencyNumberServiceImpl implements EmergencyNumberService {
  final GetEmergencyNumberUseCase _getEmergencyNumberUseCase;

  EmergencyNumberServiceImpl(this._getEmergencyNumberUseCase);

  @override
  Future<String?> getEmergencyNumber(String userId) async {
    try {
      final result = await _getEmergencyNumberUseCase(userId);
      return result.fold(
        (_) => null,
        (emergencyNumber) => emergencyNumber?.phoneNumber,
      );
    } catch (e) {
      return null;
    }
  }

  Future<String?> getEmergencyEmail(String userId) async {
    try {
      final result = await _getEmergencyNumberUseCase(userId);
      return result.fold(
        (_) => null,
        (emergencyNumber) => emergencyNumber?.email,
      );
    } catch (e) {
      return null;
    }
  }
}

