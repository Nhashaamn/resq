import 'package:freezed_annotation/freezed_annotation.dart';

part 'address.freezed.dart';

@freezed
class Address with _$Address {
  const factory Address({
    required String city,
    required String country,
    double? latitude,
    double? longitude,
  }) = _Address;
}

