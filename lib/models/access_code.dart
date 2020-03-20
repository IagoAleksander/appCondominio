enum ProfileType { unique, serviceProvider, family, undefined }

class AccessCode {
  final int id;
  String accessCodeNumber;
  ProfileType profileType;
  String createdBy;
  int creationDateInMillis;
  String createdTo;
  bool isActive = false;

  AccessCode(
      {this.id,
      this.accessCodeNumber,
      this.profileType,
      this.createdBy,
      this.creationDateInMillis,
      this.createdTo,
      this.isActive});

  Map<String, dynamic> toJson() => {
        'accessCodeNumber': accessCodeNumber,
        'profileType': profileType.toString(),
        'createdBy': createdBy,
        'creationDateInMillis': creationDateInMillis,
        'createdTo': createdTo,
        'isActive': isActive
      };

  static fromJson(Map<String, dynamic> parsedJson) {
    return AccessCode(
      id: parsedJson['id'],
      accessCodeNumber: parsedJson['accessCodeNumber'],
      profileType: profileTypeFromString(parsedJson['profileType']),
      createdBy: parsedJson['createdBy'],
      creationDateInMillis: parsedJson['creationDateInMillis'],
      createdTo: parsedJson['createdTo'],
      isActive: parsedJson['isActive'],
    );
  }

  static ProfileType profileTypeFromString(String profileType) {
    switch (profileType) {
      case "ProfileType.unique":
        return ProfileType.unique;
      case "ProfileType.serviceProvider":
        return ProfileType.serviceProvider;
      case "ProfileType.family":
        return ProfileType.family;
      default:
        return ProfileType.undefined;
    }
  }

  static String profileTypeToString(ProfileType profileType) {
    switch (profileType.toString()) {
      case "ProfileType.unique":
        return "Visita Única";
      case "ProfileType.serviceProvider":
        return "Prestador de Serviços";
      case "ProfileType.family":
        return "Família";
      default:
        return "Não Definido";
    }
  }
}
