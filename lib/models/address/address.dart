class Address {
  Address(
      {this.street,
      this.number,
      this.complement,
      this.district,
      this.zipCode,
      this.city,
      this.state,
      this.lat,
      this.long,
      this.checked = false});

  String? street;
  String? number;
  String? complement;
  String? district;
  String? zipCode;
  String? city;
  String? state;
  bool? checked;

  double? lat;
  double? long;

  Address.fromMap(Map<String, dynamic> map) {
    street = map['street'] ?? '';
    number = map['number'] ?? '';
    complement = map['complement'] ?? '';
    district = map['district'] ?? '';
    zipCode = map['zipCode'] ?? '';
    city = map['city'] ?? '';
    state = map['state'] ?? '';
    lat = map['lat'] ?? 0.0;
    long = map['long'] ?? 0.0;
    checked = map['checked'] ?? false;
  }

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'number': number,
      'complement': complement,
      'district': district,
      'zipCode': zipCode,
      'city': city,
      'state': state,
      'lat': lat,
      'long': long,
      'checked': checked,
    };
  }
}
