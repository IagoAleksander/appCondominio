class ContactInfo {
  String phoneNumber;
  String email;

  ContactInfo({this.phoneNumber, this.email});

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'email': email,
      };

  static fromJson(Map<String, dynamic> parsedJson) {
    return ContactInfo(
      phoneNumber: parsedJson['phoneNumber'],
      email: parsedJson['email'],
    );
  }
}
