

class AccessCode {
  final int id;
  String accessCodeNumber;
  String profileRuleId;
  String createdBy;
  int creationDateInMillis;
  String createdTo;
  bool isActive = false;

  AccessCode(
      {this.id,
      this.accessCodeNumber,
      this.profileRuleId,
      this.createdBy,
      this.creationDateInMillis,
      this.createdTo,
      this.isActive});

  Map<String, dynamic> toJson() => {
        'accessCodeNumber': accessCodeNumber,
        'profileRuleId': profileRuleId,
        'createdBy': createdBy,
        'creationDateInMillis': creationDateInMillis,
        'createdTo': createdTo,
        'isActive': isActive
      };

  static fromJson(Map<String, dynamic> parsedJson) {
    return AccessCode(
      accessCodeNumber: parsedJson['accessCodeNumber'],
      profileRuleId: parsedJson['profileRuleId'],
      createdBy: parsedJson['createdBy'],
      creationDateInMillis: parsedJson['creationDateInMillis'],
      createdTo: parsedJson['createdTo'],
      isActive: parsedJson['isActive'],
    );
  }
}
