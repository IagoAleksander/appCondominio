class FeedEvent {
  String id;
  String title;
  String description;
  int createdDateInMillis;
  int eventDateInMillis;
  bool isActive;
  bool sendNotification;
  String imageUrl;

  FeedEvent({
    this.title,
    this.description,
    this.createdDateInMillis,
    this.eventDateInMillis,
    this.isActive,
    this.sendNotification,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'createdDateInMillis': createdDateInMillis,
        'eventDateInMillis': eventDateInMillis,
        'isActive': isActive,
        'sendNotification': sendNotification,
        'imageUrl': imageUrl,
      };

  static fromJson(Map<String, dynamic> parsedJson) {
    return FeedEvent(
      title: parsedJson['title'],
      description: parsedJson['description'],
      createdDateInMillis: parsedJson['createdDateInMillis'],
      eventDateInMillis: parsedJson['eventDateInMillis'],
      isActive: parsedJson['isActive'],
      sendNotification: parsedJson['sendNotification'],
      imageUrl: parsedJson['imageUrl'],
    );
  }
}
