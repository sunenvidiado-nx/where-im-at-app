import 'package:dart_mappable/dart_mappable.dart';

part 'address_response.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class AddressResponse with AddressResponseMappable {
  const AddressResponse({
    required this.displayName,
    required this.address,
  });

  final String displayName;
  final AddressDetails address;
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class AddressDetails with AddressDetailsMappable {
  const AddressDetails({
    required this.city,
    required this.region,
    required this.country,
    this.stateDistrict,
    this.state,
    this.neighbourhood,
    this.quarter,
    this.road,
  });

  final String city;
  final String region;
  final String country;
  final String? stateDistrict;
  final String? state;
  final String? neighbourhood;
  final String? quarter;
  final String? road;

  String get formattedAddress {
    if (road != null && quarter != null) {
      return '$road, $quarter, $city';
    }

    if (neighbourhood != null && quarter != null) {
      return '$neighbourhood, $quarter, $city';
    }

    if (state != null) {
      return '$city, $state';
    }

    return '$city, $region';
  }
}
