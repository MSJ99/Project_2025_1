import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../utils/db.dart';
import '../models/demand_model.dart';
import '../models/property_model.dart';
import '../utils/match.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> getMatchedPropertiesForDemandHandler(
    Request req, String id) async {
  try {
    final demandDoc = await demandsCol.findOne({'_id': parseObjectId(id)});
    if (demandDoc == null) {
      return Response(404,
          body: jsonEncode({'error': '해당 Demand를 찾을 수 없습니다.'}));
    }
    final demand =
        DemandModel.fromJson({...demandDoc, 'id': demandDoc['_id'].toString()});
    final propertyDocs = await propertiesCol.find().toList();
    final matched = propertyDocs
        .map((doc) =>
            PropertyModel.fromJson({...doc, 'id': doc['_id'].toString()}))
        .where((property) => isMatchedDemandToProperty(demand, property))
        .map((property) => property.toJson())
        .toList();
    return Response.ok(
        jsonEncode({'count': matched.length, 'matched': matched}));
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}));
  }
}

Future<Response> getMatchedDemandsForPropertyHandler(
    Request req, String id) async {
  try {
    final propertyDoc = await propertiesCol.findOne({'_id': parseObjectId(id)});
    if (propertyDoc == null) {
      return Response(404,
          body: jsonEncode({'error': '해당 Property를 찾을 수 없습니다.'}));
    }
    final property = PropertyModel.fromJson(
        {...propertyDoc, 'id': propertyDoc['_id'].toString()});
    final demandDocs = await demandsCol.find().toList();
    final matched = demandDocs
        .map((doc) =>
            DemandModel.fromJson({...doc, 'id': doc['_id'].toString()}))
        .where((demand) => isMatchedDemandToProperty(demand, property))
        .map((demand) => demand.toJson())
        .toList();
    return Response.ok(
        jsonEncode({'count': matched.length, 'matched': matched}));
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}));
  }
}

ObjectId parseObjectId(String id) {
  try {
    return ObjectId.parse(id);
  } catch (_) {
    // fallback: 24자리 hex string이 아니면 그냥 id로 사용
    return ObjectId.fromHexString(id.padLeft(24, '0'));
  }
}
