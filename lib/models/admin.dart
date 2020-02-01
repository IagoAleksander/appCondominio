class Admin {
  final int id;
  final String name;
  final String email;
  final String rg;
  final String building;
  final String apartment;
  final String password;

  Admin(
      {this.id,
      this.name,
      this.email,
      this.rg,
      this.building,
      this.apartment,
      this.password});

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'rg': rg,
        'building': building,
        'apartment': apartment,
        'password': password
      };

  static fromJson(Map<String, dynamic> parsedJson) {
    return Admin(
        id: parsedJson['id'],
        name: parsedJson['name'],
        rg: parsedJson['rg'],
        email: parsedJson['email'],
        building: parsedJson['building'],
        apartment: parsedJson['apartment'],
        password: parsedJson['password']);
  }

}
