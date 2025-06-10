import 'package:mongo_dart/mongo_dart.dart';
import '../utils/db.dart';

// 매물(property) 관련 MongoDB 연동 (CRUD) (추후 구현)
class PropertyRepository {
  final DbCollection collection = propertiesCol;

  Future<List<Map<String, dynamic>>> find() async {
    final list = await collection.find().toList();
    return list.map((e) => _withId(e)).toList();
  }

  Map<String, dynamic> _withId(Map<String, dynamic> doc) {
    final map = Map<String, dynamic>.from(doc);
    map['id'] = map['_id'].toHexString();
    map.remove('_id');
    return map;
  }

  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final result = await collection.insertOne(data);
    data['_id'] = result.id;
    data['id'] = result.id.toHexString();
    data.remove('_id');
    return data;
  }

  Future<Map<String, dynamic>?> findOne(String id) async {
    final objId = ObjectId.parse(id);
    final doc = await collection.findOne({'_id': objId});
    if (doc == null) return null;
    return _withId(doc);
  }

  Future<Map<String, dynamic>?> update(
      String id, Map<String, dynamic> data) async {
    final objId = ObjectId.parse(id);
    await collection.updateOne({'_id': objId}, {r'$set': data});
    final updated = await collection.findOne({'_id': objId});
    if (updated == null) return null;
    return _withId(updated);
  }

  Future<bool> delete(String id) async {
    final objId = ObjectId.parse(id);
    final result = await collection.deleteOne({'_id': objId});
    return result.isSuccess && result.nRemoved > 0;
  }

  // 예시: insert, find, update, delete 등
}
