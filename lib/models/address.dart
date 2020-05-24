class LocationAddress {
  String addressLine;
  String subLocality;
  String city;
  String district;
  double latitude;
  double longitude;

  LocationAddress(
      {this.addressLine,
      this.subLocality,
      this.city,
      this.district,
      this.latitude,
      this.longitude});

  Map<String, dynamic> toJson() => {
        'addressLine': addressLine,
        'subLocality': subLocality,
        'city': city,
        'district': district,
        'latitude': latitude,
        'longitude': longitude
      };

  static fromJson(Map<String, dynamic> parsedJson) {
    return LocationAddress(
      addressLine: parsedJson['addressLine'],
      subLocality: parsedJson['subLocality'],
      city: parsedJson['city'],
      district: parsedJson['district'],
      latitude: parsedJson['latitude'],
      longitude: parsedJson['longitude'],
    );
  }
}
