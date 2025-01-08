

class City{
  String name;
  double latitude;
  double longitude;
  String? display_name;// Pour le champ autocomplete

  City({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.display_name,
  });

  @override
  String toString() {
    return 'City{name: $name, latitude: $latitude, longitude: $longitude, display_name: $display_name}';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': this.name,
      'latitude': this.latitude,
      'longitude': this.longitude,
    };
  }

  factory City.fromMap(Map<String, dynamic> map) {
    return City(
      name: map['name'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double
    );
  }
}