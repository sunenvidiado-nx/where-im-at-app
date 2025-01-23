import 'package:dart_mappable/dart_mappable.dart';

part 'address_response.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class AddressResponse with AddressResponseMappable {
  const AddressResponse({required this.data});

  final List<AddressData> data;
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class AddressData with AddressDataMappable {
  const AddressData({
    required this.name,
    required this.country,
    required this.label,
    required this.locality,
  });

  final String name;
  final String country;
  final String label;
  final String locality;
}
