class ProfileRule {
  String id;
  String title;
  int value;
  String unit;
  bool isActive;

  ProfileRule({
    this.title,
    this.value,
    this.unit,
    this.isActive,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'value': value,
        'unit': unit,
        'isActive': isActive,
      };

  static fromJson(Map<String, dynamic> parsedJson) {
    return ProfileRule(
      title: parsedJson['title'],
      value: parsedJson['value'],
      unit: parsedJson['unit'],
      isActive: parsedJson['isActive'],
    );
  }
}
