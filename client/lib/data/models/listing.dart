abstract class Listing {
  final String? id;
  final String tradeType;
  final int price;
  final String contact;

  Listing({
    this.id,
    required this.tradeType,
    required this.price,
    required this.contact,
  });

  Map<String, dynamic> toJson();
}
