import 'listing.dart';

class Property extends Listing {
  final String? id;
  final String image;
  final String address;
  final String floor;
  final double area;
  final List<String> options;
  final int roomCount;
  final String propertyType;
  final DateTime moveInDate;
  final int? monthlyRent;
  final double? lat;
  final double? lng;

  Property({
    this.id,
    required this.image,
    required this.address,
    required String tradeType,
    required this.floor,
    required this.area,
    required int price,
    required this.options,
    required this.roomCount,
    required this.propertyType,
    required this.moveInDate,
    this.monthlyRent,
    required String contact,
    this.lat,
    this.lng,
  }) : super(id: id, tradeType: tradeType, price: price, contact: contact);

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] ?? json['_id']?.toString(),
      image: json['image'] ?? '',
      address: json['address'] ?? '',
      tradeType: json['tradeType'] ?? '',
      floor: json['floor']?.toString() ?? '',
      area: double.tryParse(json['area']?.toString() ?? '0') ?? 0.0,
      price: int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      options:
          (json['options'] is String)
              ? (json['options'] as String)
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList()
              : (json['options'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [],
      roomCount: int.tryParse(json['roomCount']?.toString() ?? '0') ?? 0,
      propertyType: json['propertyType'] ?? '',
      moveInDate:
          json['moveInDate'] != null
              ? DateTime.tryParse(json['moveInDate'].toString()) ??
                  DateTime(2025)
              : DateTime(2025),
      monthlyRent:
          json['monthlyRent'] != null
              ? int.tryParse(json['monthlyRent'].toString())
              : null,
      contact: json['contact'] ?? '',
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.tryParse(json['lng'].toString()) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'image': image,
      'address': address,
      'tradeType': tradeType,
      'floor': floor,
      'area': area,
      'price': price,
      'options': options,
      'roomCount': roomCount,
      'propertyType': propertyType,
      'moveInDate': moveInDate.toIso8601String(),
      if (monthlyRent != null) 'monthlyRent': monthlyRent,
      'contact': contact,
      'lat': lat,
      'lng': lng,
    };
  }
}
