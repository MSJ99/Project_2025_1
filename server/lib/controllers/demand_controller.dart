import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../repositories/demand_repository.dart';
import '../models/demand_model.dart';
import 'dart:developer';

final demandRepo = DemandRepository();

Future<Response> addDemandHandler(Request req) async {
  print('[demand_controller] addDemandHandler called');
  try {
    final body = await req.readAsString();
    final data = jsonDecode(body);
    final demand = DemandModel(
      tradeType: data['tradeType'] ?? '',
      price: int.tryParse(data['price']?.toString() ?? '0') ?? 0,
      contact: data['contact'] ?? '',
      customerName: data['customerName'],
      floor: data['floor']?.toString(),
      area: data['area'] != null
          ? double.tryParse(data['area'].toString())
          : null,
      options: (data['options'] is String)
          ? (data['options'] as String)
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
          : (data['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(),
      roomCount: data['roomCount'] != null
          ? int.tryParse(data['roomCount'].toString())
          : null,
      propertyType: data['propertyType'] ?? '',
      moveInDate: data['moveInDate'] != null
          ? DateTime.tryParse(data['moveInDate'].toString())
          : null,
      monthlyRent: data['monthlyRent'] != null
          ? int.tryParse(data['monthlyRent'].toString())
          : null,
    );
    final id = await demandRepo.insert(demand);
    final result = demand.toJson();
    result['id'] = id.toString();
    return Response.ok(jsonEncode(result));
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}));
  }
}

Future<Response> listDemandsHandler(Request req) async {
  print('[demand_controller] listDemandsHandler called');
  try {
    final list = await demandRepo.find();
    return Response.ok(jsonEncode(list));
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}));
  }
}

Future<Response> getDemandHandler(Request req, String id) async {
  try {
    final demand = await demandRepo.findOne(id);
    if (demand == null) {
      return Response.notFound(jsonEncode({'error': 'Not found'}));
    }
    demand['id'] = demand['_id'].toString();
    demand.remove('_id');
    return Response.ok(jsonEncode(demand));
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}));
  }
}

Future<Response> editDemandHandler(Request req, String id) async {
  print('[editDemandHandler] called with id=$id');
  try {
    final body = await req.readAsString();
    final data = jsonDecode(body);
    // 숫자/리스트 필드 변환
    if (data['roomCount'] != null) {
      data['roomCount'] = int.tryParse(data['roomCount'].toString());
    }
    if (data['monthlyRent'] != null) {
      data['monthlyRent'] = int.tryParse(data['monthlyRent'].toString());
    }
    if (data['area'] != null) {
      data['area'] = double.tryParse(data['area'].toString());
    }
    if (data['price'] != null) {
      data['price'] = int.tryParse(data['price'].toString());
    }
    if (data['options'] != null && data['options'] is String) {
      data['options'] = (data['options'] as String)
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (data['customerName'] != null) {
      data['customerName'] = data['customerName'];
      data.remove('customerName');
    }
    final ok = await demandRepo.update(id, data);
    if (!ok) {
      return Response.internalServerError(
          body: jsonEncode({'error': 'Update failed'}));
    }
    final updated = await demandRepo.findOne(id);
    return Response.ok(jsonEncode(updated));
  } catch (e, st) {
    print('[editDemandHandler] error: $e\n$st');
    return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}));
  }
}

Future<Response> deleteDemandHandler(Request req, String id) async {
  try {
    final ok = await demandRepo.delete(id);
    if (!ok) {
      return Response.internalServerError(
          body: jsonEncode({'error': 'Delete failed'}));
    }
    return Response.ok(jsonEncode({'success': true}));
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}));
  }
}
