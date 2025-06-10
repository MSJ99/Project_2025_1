import 'package:mongo_dart/mongo_dart.dart';
import '../models/user_model.dart';

class UserRepository {
  final Db db;
  UserRepository(this.db);

  Future<User?> findByGoogleId(String googleId) async {
    final users = db.collection('users');
    final existing = await users.findOne({'googleId': googleId});
    if (existing == null) return null;
    return User(
      id: existing['_id'].toHexString(),
      googleId: existing['googleId'],
      email: existing['email'],
    );
  }

  Future<User> create(String googleId, String email) async {
    final users = db.collection('users');
    final result =
        await users.insertOne({'googleId': googleId, 'email': email});
    final newUser = await users.findOne({'_id': result.id});
    return User(
      id: newUser!['_id'].toHexString(),
      googleId: newUser['googleId'],
      email: newUser['email'],
    );
  }

  Future<User?> findById(String id) async {
    final users = db.collection('users');
    final objId = ObjectId.parse(id);
    final existing = await users.findOne({'_id': objId});
    if (existing == null) return null;
    return User(
      id: existing['_id'].toHexString(),
      googleId: existing['googleId'],
      email: existing['email'],
    );
  }
}
