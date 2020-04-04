enum Status { pendingApproval, active, inactive, undefined }

class User {
  final int id;
  final String name;
  final String email;
  final String rg;
  final String building;
  final String apartment;
  final String password;
  Status status;
  String notificationToken;
  bool isAdmin;

  User(
      {this.id,
      this.name,
      this.email,
      this.rg,
      this.building,
      this.apartment,
      this.password,
      this.status,
      this.notificationToken,
      this.isAdmin = false});

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'rg': rg,
        'building': building,
        'apartment': apartment,
        'password': password,
        'status': status.toString(),
        'notificationToken': notificationToken,
        'isAdmin': isAdmin
      };

  static fromJson(Map<String, dynamic> parsedJson) {
    return User(
        id: parsedJson['id'],
        name: parsedJson['name'],
        rg: parsedJson['rg'],
        email: parsedJson['email'],
        building: parsedJson['building'],
        apartment: parsedJson['apartment'],
        password: parsedJson['password'],
        status: statusFromString(parsedJson['status']),
        notificationToken: parsedJson['notificationToken'],
        isAdmin: parsedJson['isAdmin']);
  }

  static Status statusFromString(String status) {
    switch (status) {
      case "Status.active":
        return Status.active;
      case "Status.inactive":
        return Status.inactive;
      case "Status.pendingApproval":
        return Status.pendingApproval;
      default:
        return Status.undefined;
    }
  }
}
