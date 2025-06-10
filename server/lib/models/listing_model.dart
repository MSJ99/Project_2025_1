abstract class ListingModel {
  final String tradeType;
  final int price;
  final String contact;

  ListingModel({
    required this.tradeType,
    required this.price,
    required this.contact,
  });

  Map<String, dynamic> toJson();
}
