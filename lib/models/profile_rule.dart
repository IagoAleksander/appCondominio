class ProfileRule {
  String id;
  String title;
  int value;
  String unit;

  ProfileRule({
    this.title,
    this.value,
    this.unit,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'value': value,
        'unit': unit,
      };

  static fromJson(Map<String, dynamic> parsedJson) {
    return ProfileRule(
      title: parsedJson['title'],
      value: parsedJson['value'],
      unit: parsedJson['unit'],
    );
  }
}
