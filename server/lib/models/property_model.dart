import 'listing_model.dart';

class PropertyModel extends ListingModel {
  final String address;
  final String floor; // 숫자 또는 '저층/중층/고층' 문자열 허용
  final double area;
  final List<String> options;
  final int roomCount;
  final String propertyType;
  final DateTime moveInDate;
  final int? monthlyRent;
  final String image;
  final double? lat;
  final double? lng;

  PropertyModel({
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
    required this.image,
    this.lat,
    this.lng,
  }) : super(tradeType: tradeType, price: price, contact: contact);

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      address: json['address'] ?? '',
      tradeType: json['tradeType'] ?? '',
      floor: json['floor']?.toString() ?? '',
      area: double.tryParse(json['area']?.toString() ?? '0') ?? 0.0,
      price: int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      options: (json['options'] is String)
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
      moveInDate: json['moveInDate'] != null
          ? DateTime.tryParse(json['moveInDate'].toString()) ?? DateTime(2025)
          : DateTime(2025),
      monthlyRent: json['monthlyRent'] != null
          ? int.tryParse(json['monthlyRent'].toString())
          : null,
      contact: json['contact'] ?? '',
      image: json['image'] ?? '',
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.tryParse(json['lng'].toString()) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
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
      'image': image,
      'lat': lat,
      'lng': lng,
    };
  }
}
