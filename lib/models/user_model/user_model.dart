import '../../maps/geo_coordinate.dart';

class UserModel {
  String? bAddress;
  String? hAddress;
  String? mallAddress;
  String? name;
  String? image;
  GeoCoordinate? homeAddress;
  GeoCoordinate? businessAddress;
  GeoCoordinate? shoppingAddress;

  UserModel({
    this.name,
    this.bAddress,
    this.hAddress,
    this.image,
    this.mallAddress,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    bAddress = json['business_address'];
    hAddress = json['home_address'];
    mallAddress = json['shopping_address'];
    name = json['name'];
    image = json['image'];
    homeAddress = _coordinate(json['home_latlng']);
    businessAddress = _coordinate(json['business_latlng']);
    shoppingAddress = _coordinate(json['shopping_latlng']);
  }

  static GeoCoordinate? _coordinate(dynamic value) {
    if (value == null) return null;
    try {
      final point = GeoCoordinate(
        (value.latitude as num).toDouble(),
        (value.longitude as num).toDouble(),
      );
      return point.isValid ? point : null;
    } on NoSuchMethodError {
      return null;
    } on TypeError {
      return null;
    }
  }
}
