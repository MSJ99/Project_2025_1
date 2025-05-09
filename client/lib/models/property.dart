class Property {
  final String image;
  final String address;
  final String type;
  final int floor;
  final double area;
  final int price;
  final String options;
  final String contact;
  final List<String> tags;
  final bool isFavorite;

  Property({
    required this.image,
    required this.address,
    required this.type,
    required this.floor,
    required this.area,
    required this.price,
    required this.options,
    required this.contact,
    required this.tags,
    required this.isFavorite,
  });
}
