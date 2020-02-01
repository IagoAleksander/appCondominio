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

  User(
      {this.id,
      this.name,
      this.email,
      this.rg,
      this.building,
      this.apartment,
      this.password,
      this.status});

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'rg': rg,
        'building': building,
        'apartment': apartment,
        'password': password,
        'status': status.toString()
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
        status: statusFromString(parsedJson['status']));
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
