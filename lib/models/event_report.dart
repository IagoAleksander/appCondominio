class EventReport {
  String id;
  String title;
  String description;

  EventReport({
    this.title,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
      };

  static fromJson(Map<String, dynamic> parsedJson) {
    return EventReport(
      title: parsedJson['title'],
      description: parsedJson['description'],
    );
  }
}
