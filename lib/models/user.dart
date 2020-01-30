enum Status { pendingApproval, active, inactive }

class User {
  final int id;
  final String name;
  final String email;
  final String rg;
  final String apartment;
  final String password;
  Status status;

  User(
      {this.id,
      this.name,
      this.email,
      this.rg,
      this.apartment,
      this.password,
      this.status});

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'rg': rg,
        'apartment': apartment,
        'password': password,
        'status': status.toString()
      };
}
