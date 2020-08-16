class Meeting {
  String id;
  String title;
  String description;
  int createdDateInMillis;
  int meetingDateInMillis;
  bool isActive;
  bool sendNotification;
  String videoID;

  Meeting({
    this.title,
    this.description,
    this.createdDateInMillis,
    this.meetingDateInMillis,
    this.isActive,
    this.sendNotification,
    this.videoID,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'createdDateInMillis': createdDateInMillis,
        'meetingDateInMillis': meetingDateInMillis,
        'isActive': isActive,
        'sendNotification': sendNotification,
        'videoID': videoID,
      };

  static fromJson(Map<String, dynamic> parsedJson) {
    return Meeting(
      title: parsedJson['title'],
      description: parsedJson['description'],
      createdDateInMillis: parsedJson['createdDateInMillis'],
      meetingDateInMillis: parsedJson['meetingDateInMillis'],
      isActive: parsedJson['isActive'],
      sendNotification: parsedJson['sendNotification'],
      videoID: parsedJson['videoID'],
    );
  }
}
