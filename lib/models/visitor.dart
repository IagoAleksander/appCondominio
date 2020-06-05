import 'access_code.dart';

class Visitor {
  String id;
  final String name;
  final String rg;
  final String rgUrl;
  final String phoneNumber;
  final String registeredBy;
  bool isLiberated = false;
  AccessCode accessCode;

  Visitor({
    this.id,
    this.name,
    this.rg,
    this.rgUrl,
    this.phoneNumber,
    this.registeredBy,
    this.isLiberated,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'rg': rg,
        'rgUrl': rgUrl,
        'phoneNumber': phoneNumber,
        'registeredBy': registeredBy,
        'isLiberated': isLiberated,
      };

  static fromJson(Map<String, dynamic> parsedJson) {
    return Visitor(
      id: parsedJson['id'],
      name: parsedJson['name'],
      rg: parsedJson['rg'],
      rgUrl: parsedJson['rgUrl'],
      phoneNumber: parsedJson['phoneNumber'],
      registeredBy: parsedJson['registeredBy'],
      isLiberated: parsedJson['isLiberated'],
    );
  }
}
