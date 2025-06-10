import 'listing.dart';

class Demand extends Listing {
  final String? customerName;
  final String? floor;
  final double? area;
  final List<String>? options;
  final int? roomCount;
  final String? propertyType;
  final DateTime? moveInDate;
  final int? monthlyRent;

  Demand({
    String? id,
    required String tradeType,
    required int price,
    required String contact,
    this.customerName,
    this.floor,
    this.area,
    this.options,
    this.roomCount,
    this.propertyType,
    this.moveInDate,
    this.monthlyRent,
  }) : super(id: id, tradeType: tradeType, price: price, contact: contact);

  factory Demand.fromJson(Map<String, dynamic> json) {
    return Demand(
      id: json['id'] ?? json['_id']?.toString(),
      tradeType: json['tradeType'] ?? '',
      price: int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      contact: json['contact'] ?? '',
      customerName: json['customerName'],
      floor: json['floor']?.toString(),
      area:
          json['area'] != null
              ? double.tryParse(json['area'].toString())
              : null,
      options:
          (json['options'] is String)
              ? (json['options'] as String)
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList()
              : (json['options'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList(),
      roomCount:
          json['roomCount'] != null
              ? int.tryParse(json['roomCount'].toString())
              : null,
      propertyType: json['propertyType'],
      moveInDate:
          json['moveInDate'] != null
              ? DateTime.tryParse(json['moveInDate'].toString())
              : null,
      monthlyRent:
          json['monthlyRent'] != null
              ? int.tryParse(json['monthlyRent'].toString())
              : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'tradeType': tradeType,
      'price': price,
      'contact': contact,
      if (customerName != null) 'customerName': customerName,
      if (floor != null) 'floor': floor,
      if (area != null) 'area': area,
      if (options != null) 'options': options,
      if (roomCount != null) 'roomCount': roomCount,
      if (propertyType != null) 'propertyType': propertyType,
      if (moveInDate != null) 'moveInDate': moveInDate?.toIso8601String(),
      if (monthlyRent != null) 'monthlyRent': monthlyRent,
    };
  }
}
