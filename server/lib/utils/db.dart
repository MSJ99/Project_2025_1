import 'package:mongo_dart/mongo_dart.dart';
import '../models/user_model.dart';
import 'dart:developer';

late Db db;
late DbCollection usersCol;
late DbCollection propertiesCol;
late DbCollection demandsCol;

Future<void> connectDb() async {
  try {
    print('[DB] MongoDB 연결 시도...');
    db = await Db.create('mongodb://localhost:27017/palbang');
    await db.open();
    print('[DB] MongoDB 연결 성공!');
    usersCol = db.collection('users');
    propertiesCol = db.collection('properties');
    demandsCol = db.collection('demands');
    print('[DB] 컬렉션(users, properties, demands) 초기화 완료');
  } catch (e, st) {
    print('[DB] MongoDB 연결 실패: $e\n$st');
    rethrow;
  }
}

Future<User> findOrCreateUser(Db db, String googleId, String email) async {
  final users = db.collection('users');
  final existing = await users.findOne({'googleId': googleId});
  if (existing != null) {
    return User(
      id: existing['_id'].toHexString(),
      googleId: existing['googleId'],
      email: existing['email'],
    );
  }
  final result = await users.insertOne({'googleId': googleId, 'email': email});
  final newUser = await users.findOne({'_id': result.id});
  return User(
    id: newUser!['_id'].toHexString(),
    googleId: newUser['googleId'],
    email: newUser['email'],
  );
}
