class AccessHistory {
  int accessAt;
  String accessCodeNumber;

  AccessHistory({
    this.accessAt,
    this.accessCodeNumber,
  });

  Map<String, dynamic> toJson() => {
        'accessAt': accessAt,
        'accessCodeNumber': accessCodeNumber,
      };

  static fromJson(Map<String, dynamic> parsedJson) {
    return AccessHistory(
      accessAt: parsedJson['accessAt'],
      accessCodeNumber: parsedJson['accessCodeNumber'],
    );
  }
}
