class User {
  final String id;
  final String googleId;
  final String email;
  User({required this.id, required this.googleId, required this.email});
  Map<String, dynamic> toJson() =>
      {'id': id, 'googleId': googleId, 'email': email};
}
