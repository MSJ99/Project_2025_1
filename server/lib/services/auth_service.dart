import '../repositories/user_repository.dart';
import '../models/user_model.dart';

class AuthService {
  final UserRepository userRepository;
  AuthService(this.userRepository);

  Future<User> findOrCreateUser(String googleId, String email) async {
    final user = await userRepository.findByGoogleId(googleId);
    if (user != null) return user;
    return await userRepository.create(googleId, email);
  }

  Future<User?> findById(String id) async {
    return await userRepository.findById(id);
  }

  Future<User?> findByEmail(String email) async {
    final users = userRepository.db.collection('users');
    final existing = await users.findOne({'email': email});
    if (existing == null) return null;
    return User(
      id: existing['_id'].toHexString(),
      googleId: existing['googleId'],
      email: existing['email'],
    );
  }
}
