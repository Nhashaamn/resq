import 'package:resq/features/func/domain/entities/address.dart' as domain;

class AddressModel {
  final String city;
  final String country;
  final double? latitude;
  final double? longitude;

  AddressModel({
    required this.city,
    required this.country,
    this.latitude,
    this.longitude,
  });

  factory AddressModel.fromFirestore(Map<String, dynamic> map) {
    return AddressModel(
      city: map['city'] as String? ?? '',
      country: map['country'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'city': city,
      'country': country,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  domain.Address toDomain() {
    return domain.Address(
      city: city,
      country: country,
      latitude: latitude,
      longitude: longitude,
    );
  }

  factory AddressModel.fromDomain(domain.Address address) {
    return AddressModel(
      city: address.city,
      country: address.country,
      latitude: address.latitude,
      longitude: address.longitude,
    );
  }
}

