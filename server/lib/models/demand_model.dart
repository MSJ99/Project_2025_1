import 'listing_model.dart';

class DemandModel extends ListingModel {
  final String? customerName;
  final String? floor; // 숫자 또는 '저층/중층/고층' 문자열 허용
  final double? area;
  final List<String>? options;
  final int? roomCount;
  final String propertyType; // Null 불가
  final DateTime? moveInDate;
  final int? monthlyRent;

  DemandModel({
    required String tradeType,
    required int price,
    required String contact,
    this.customerName,
    this.floor,
    this.area,
    this.options,
    this.roomCount,
    required this.propertyType,
    this.moveInDate,
    this.monthlyRent,
  }) : super(tradeType: tradeType, price: price, contact: contact);

  factory DemandModel.fromJson(Map<String, dynamic> json) {
    return DemandModel(
      tradeType: json['tradeType'] ?? '',
      price: int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      contact: json['contact'] ?? '',
      customerName: json['customerName'],
      floor: json['floor']?.toString(),
      area: json['area'] != null
          ? double.tryParse(json['area'].toString())
          : null,
      options: (json['options'] is String)
          ? (json['options'] as String)
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
          : (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(),
      roomCount: json['roomCount'] != null
          ? int.tryParse(json['roomCount'].toString())
          : null,
      propertyType: json['propertyType'] ?? '',
      moveInDate: json['moveInDate'] != null
          ? DateTime.tryParse(json['moveInDate'].toString())
          : null,
      monthlyRent: json['monthlyRent'] != null
          ? int.tryParse(json['monthlyRent'].toString())
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'tradeType': tradeType,
      'price': price,
      'contact': contact,
      if (customerName != null) 'customerName': customerName,
      if (floor != null) 'floor': floor,
      if (area != null) 'area': area,
      if (options != null) 'options': options,
      if (roomCount != null) 'roomCount': roomCount,
      'propertyType': propertyType,
      if (moveInDate != null) 'moveInDate': moveInDate?.toIso8601String(),
      if (monthlyRent != null) 'monthlyRent': monthlyRent,
    };
  }
}
