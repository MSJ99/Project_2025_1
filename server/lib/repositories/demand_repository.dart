import 'package:mongo_dart/mongo_dart.dart';
import '../utils/db.dart';
import '../models/demand_model.dart';

class DemandRepository {
  final DbCollection collection = demandsCol;

  Future<String> insert(DemandModel demand) async {
    final result = await collection.insertOne(demand.toJson());
    return result.id.toHexString();
  }

  Future<List<Map<String, dynamic>>> find() async {
    final list = await collection.find().toList();
    return list.map((e) => _withId(e)).toList();
  }

  Future<Map<String, dynamic>?> findOne(String id) async {
    final obj = await collection.findOne(where.id(ObjectId.parse(id)));
    return obj != null ? _withId(obj) : null;
  }

  Future<bool> update(String id, Map<String, dynamic> data) async {
    try {
      final result = await collection.updateOne(
        where.id(ObjectId.parse(id)),
        {r'$set': data},
      );
      print(
          'updateOne result: matched=${result.nMatched}, modified=${result.nModified}, isSuccess=${result.isSuccess}');
      return result.nMatched > 0;
    } catch (e) {
      print('updateOne error: $e');
      return false;
    }
  }

  Future<bool> delete(String id) async {
    final result = await collection.deleteOne(where.id(ObjectId.parse(id)));
    return result.isSuccess;
  }

  Map<String, dynamic> _withId(Map<String, dynamic> doc) {
    final map = Map<String, dynamic>.from(doc);
    map['id'] = map['_id'].toHexString();
    map.remove('_id');
    return map;
  }
}
