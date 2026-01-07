import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resq/core/di/injection.dart';
import 'package:resq/features/func/domain/entities/address.dart';
import 'package:resq/features/func/domain/usecases/get_address_usecase.dart';
import 'package:resq/features/func/domain/usecases/save_address_usecase.dart';

final addressProvider = StateNotifierProvider<AddressNotifier, AddressState>((ref) {
  return AddressNotifier();
});

class AddressState {
  final Address? address;
  final bool isLoading;
  final String? error;

  AddressState({
    this.address,
    this.isLoading = false,
    this.error,
  });

  AddressState copyWith({
    Address? address,
    bool? isLoading,
    String? error,
  }) {
    return AddressState(
      address: address ?? this.address,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AddressNotifier extends StateNotifier<AddressState> {
  AddressNotifier() : super(AddressState()) {
    // Use Future.microtask to avoid modifying provider during initialization
    Future.microtask(() => loadAddress());
  }

  Future<void> loadAddress() async {
    state = state.copyWith(isLoading: true, error: null);
    final getAddressUseCase = getIt<GetAddressUseCase>();
    final result = await getAddressUseCase();
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.when(
            server: (msg) => msg,
            network: (msg) => msg,
            cache: (msg) => msg,
            validation: (msg) => msg,
            auth: (msg) => msg,
          ),
        );
      },
      (address) {
        state = state.copyWith(
          address: address,
          isLoading: false,
        );
      },
    );
  }

  Future<bool> saveAddress(
    String city,
    String country,
    double? latitude,
    double? longitude,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    final saveAddressUseCase = getIt<SaveAddressUseCase>();
    final result = await saveAddressUseCase(city, country, latitude, longitude);
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.when(
            server: (msg) => msg,
            network: (msg) => msg,
            cache: (msg) => msg,
            validation: (msg) => msg,
            auth: (msg) => msg,
          ),
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
        );
        loadAddress(); // Reload to get updated address
        return true;
      },
    );
  }
}

