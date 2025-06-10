import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../utils/db.dart';
import '../repositories/demand_repository.dart';
import '../repositories/property_repository.dart';
import '../models/demand_model.dart';
import '../models/property_model.dart';
import '../utils/match.dart';
import 'dart:developer';
import 'package:shelf_multipart/multipart.dart';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';
import 'package:dotenv/dotenv.dart';
import '../services/property_service.dart';

final dotenv = DotEnv()..load();
final propertyService =
    PropertyService(PropertyRepository(), DemandRepository());

Future<List<double>?> fetchLatLngFromAddress(String address) async {
  print('[fetchLatLngFromAddress] 요청 주소: $address');
  final apiKeyId = dotenv['NMF_CLIENT_ID'] ?? '';
  final apiKey = dotenv['NMF_CLIENT_SECRET_ID'] ?? '';
  final url = Uri.parse(
      'https://maps.apigw.ntruss.com/map-geocode/v2/geocode?query=${Uri.encodeComponent(address)}');
  print('[fetchLatLngFromAddress] 네이버 API 호출: $url');
  final response = await HttpClient().getUrl(url)
    ..headers.set('X-NCP-APIGW-API-KEY-ID', apiKeyId)
    ..headers.set('X-NCP-APIGW-API-KEY', apiKey)
    ..headers.set('Accept', 'application/json');
  final res = await (await response.close()).transform(utf8.decoder).join();
  print('[fetchLatLngFromAddress] 네이버 API 응답: $res');
  final data = jsonDecode(res);
  if (data['addresses'] != null && data['addresses'].isNotEmpty) {
    final addr = data['addresses'][0];
    final lat = double.parse(addr['y']);
    final lng = double.parse(addr['x']);
    print('[fetchLatLngFromAddress] 변환 성공: lat=$lat, lng=$lng');
    return [lat, lng];
  }
  print('[fetchLatLngFromAddress] 변환 실패: $address');
  return null;
}

Future<Response> addPropertyHandler(Request req) async {
  print('[property_controller] addPropertyHandler called');
  final contentType = req.headers['content-type'] ?? '';
  if (contentType.contains('multipart/form-data')) {
    final boundary = contentType.split('boundary=')[1];
    final transformer = MimeMultipartTransformer(boundary);
    final bodyStream = req.read();
    final parts = await transformer.bind(bodyStream).toList();
    Map<String, dynamic> data = {};
    String? imageUrl;
    for (final part in parts) {
      final header = part.headers['content-disposition']!;
      final nameMatch = RegExp(r'name="([^"]*)"').firstMatch(header);
      final filenameMatch = RegExp(r'filename="([^"]*)"').firstMatch(header);
      final name = nameMatch?.group(1);
      if (filenameMatch != null) {
        // 파일 저장
        final filename = filenameMatch.group(1)!;
        final uploadDir = Directory('uploads');
        if (!await uploadDir.exists()) await uploadDir.create();
        final filePath = p.join('uploads', filename);
        final file = File(filePath);
        final bytesList = await part.toList();
        final bytes = bytesList.expand((e) => e).toList();
        await file.writeAsBytes(bytes);
        imageUrl = filePath;
      } else if (name != null) {
        final value = await utf8.decoder.bind(part).join();
        data[name] = value;
      }
    }
    if (imageUrl != null) data['image'] = imageUrl;
    if (data['address'] != null && data['address'].toString().isNotEmpty) {
      final latLng = await fetchLatLngFromAddress(data['address']);
      if (latLng != null) {
        data['lat'] = latLng[0];
        data['lng'] = latLng[1];
      } else {
        print('[property_controller] 주소로 위경도 변환 실패: \'${data['address']}\'');
      }
    }
    // 숫자 필드 변환
    if (data['roomCount'] != null) {
      data['roomCount'] = int.tryParse(data['roomCount'].toString()) ?? 0;
    }
    if (data['monthlyRent'] != null) {
      data['monthlyRent'] = int.tryParse(data['monthlyRent'].toString());
    }
    if (data['area'] != null) {
      data['area'] = double.tryParse(data['area'].toString()) ?? 0.0;
    }
    if (data['price'] != null) {
      data['price'] = int.tryParse(data['price'].toString()) ?? 0;
    }
    final result = await propertyService.addProperty(data);
    if (result != null && result['id'] != null) {
      return Response.ok(jsonEncode(result));
    } else {
      return Response.internalServerError(body: jsonEncode({'error': '등록 실패'}));
    }
  } else if (contentType.contains('application/json')) {
    final body = await req.readAsString();
    final data = jsonDecode(body);
    if (data['address'] != null && data['address'].toString().isNotEmpty) {
      final latLng = await fetchLatLngFromAddress(data['address']);
      if (latLng != null) {
        data['lat'] = latLng[0];
        data['lng'] = latLng[1];
      }
    }
    final result = await propertyService.addProperty(data);
    if (result != null && result['id'] != null) {
      return Response.ok(jsonEncode(result));
    } else {
      return Response.internalServerError(body: jsonEncode({'error': '등록 실패'}));
    }
  } else {
    return Response(400, body: 'Unsupported Content-Type');
  }
}

Future<Response> listPropertiesHandler(Request req) async {
  print('[property_controller] listPropertiesHandler called');
  final list = await propertiesCol.find().toList();
  // 각 매물에 대해 _id를 문자열 id로 변환
  final newList = list.map((item) {
    item['id'] = (item['_id'] is ObjectId)
        ? item['_id'].toHexString()
        : item['_id'].toString();
    item.remove('_id');
    return item;
  }).toList();
  return Response.ok(jsonEncode(newList));
}

Future<Response> getPropertyHandler(Request req, String id) async {
  final property = await propertiesCol.findOne({'_id': ObjectId.parse(id)});
  if (property == null) {
    return Response(404, body: jsonEncode({'error': '매물을 찾을 수 없습니다.'}));
  }
  property['id'] = (property['_id'] is ObjectId)
      ? property['_id'].toHexString()
      : property['_id'].toString();
  property.remove('_id');
  return Response.ok(jsonEncode(property));
}

Future<Response> editPropertyHandler(Request req, String id) async {
  final contentType = req.headers['content-type'] ?? '';
  Map<String, dynamic> data = {};
  final origin = await propertiesCol.findOne({'_id': ObjectId.parse(id)});
  if (origin == null) {
    return Response(404, body: jsonEncode({'error': '매물을 찾을 수 없습니다.'}));
  }
  if (contentType.contains('multipart/form-data')) {
    final boundary = contentType.split('boundary=')[1];
    final transformer = MimeMultipartTransformer(boundary);
    final bodyStream = req.read();
    final parts = await transformer.bind(bodyStream).toList();
    String? imageUrl;
    for (final part in parts) {
      final header = part.headers['content-disposition']!;
      final nameMatch = RegExp(r'name="([^"]*)"').firstMatch(header);
      final filenameMatch = RegExp(r'filename="([^"]*)"').firstMatch(header);
      final name = nameMatch?.group(1);
      if (filenameMatch != null) {
        // 파일 저장
        final filename = filenameMatch.group(1)!;
        final uploadDir = Directory('uploads');
        if (!await uploadDir.exists()) await uploadDir.create();
        final filePath = p.join('uploads', filename);
        final file = File(filePath);
        final bytesList = await part.toList();
        final bytes = bytesList.expand((e) => e).toList();
        await file.writeAsBytes(bytes);
        imageUrl = filePath;
      } else if (name != null) {
        final value = await utf8.decoder.bind(part).join();
        data[name] = value;
      }
    }
    if (imageUrl != null) data['image'] = imageUrl;
    // 이미지 첨부가 없으면 기존 이미지 유지
    if (data['image'] == null || data['image'] == '') {
      if (origin['image'] != null) {
        data['image'] = origin['image'];
      }
    }
  } else if (contentType.contains('application/json')) {
    final body = await req.readAsString();
    data = jsonDecode(body);
  } else {
    return Response(400, body: 'Unsupported Content-Type');
  }

  // 주소 변경 시 또는 lat/lng가 없을 때 위경도 갱신
  if (data['address'] != null && data['address'].toString().isNotEmpty) {
    bool needLatLng = false;
    if (data['lat'] == null ||
        data['lng'] == null ||
        data['lat'].toString().isEmpty ||
        data['lng'].toString().isEmpty) {
      needLatLng = true;
    }
    if (needLatLng) {
      final latLng = await fetchLatLngFromAddress(data['address']);
      if (latLng != null) {
        data['lat'] = latLng[0];
        data['lng'] = latLng[1];
      }
    }
  }

  // 숫자 필드 변환
  if (data['roomCount'] != null) {
    data['roomCount'] = int.tryParse(data['roomCount'].toString()) ?? 0;
  }
  if (data['monthlyRent'] != null) {
    data['monthlyRent'] = int.tryParse(data['monthlyRent'].toString());
  }
  if (data['area'] != null) {
    data['area'] = double.tryParse(data['area'].toString()) ?? 0.0;
  }
  if (data['price'] != null) {
    data['price'] = int.tryParse(data['price'].toString()) ?? 0;
  }

  // 기존 값과 새 값 merge (id, _id 등 제외)
  final merged = {...origin};
  data.forEach((key, value) {
    if (value != null && value.toString().isNotEmpty) {
      merged[key] = value;
    }
  });
  merged.remove('_id');
  merged.remove('id');

  final result = await propertyService.editProperty(id, merged);
  if (result != null && result['id'] != null) {
    return Response.ok(jsonEncode(result));
  }
  return Response.internalServerError(body: jsonEncode({'error': '수정 실패'}));
}

Future<Response> deletePropertyHandler(Request req, String id) async {
  final result = await propertiesCol.deleteOne({'_id': ObjectId.parse(id)});
  final property = await propertiesCol.findOne({'_id': ObjectId.parse(id)});
  if (property != null &&
      property['image'] != null &&
      property['image'].toString().isNotEmpty) {
    final imagePath = property['image'].toString();
    if (imagePath.startsWith('uploads/')) {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
  return Response.ok(
      jsonEncode({'success': result.isSuccess && result.nRemoved > 0}));
}

Future<Response> matchPropertiesForDemandHandler(
    Request req, String demandId) async {
  print('[매칭API] demandId=$demandId');
  try {
    // 1. 해당 Demand 조회
    Map<String, dynamic>? demandMap;
    try {
      demandMap = await propertyService.findOneDemand(demandId);
    } catch (e) {
      // ObjectId 파싱 실패 등
      return Response(200, body: jsonEncode([])); // 매칭 없음은 200
    }
    if (demandMap == null) {
      // demand가 없으면 매칭 없음 취급
      return Response(200, body: jsonEncode([]));
    }
    final demand = DemandModel.fromJson(demandMap);
    // 2. 모든 Property 조회 (find() 구현 필요)
    final propertyList = await propertyService.find();
    final matched = <Map<String, dynamic>>[];
    for (final propMap in propertyList) {
      final property = PropertyModel.fromJson(propMap);
      if (isMatchedDemandToProperty(demand, property)) {
        matched.add(propMap);
      }
    }
    return Response(200,
        body: jsonEncode({
          'count': matched.length,
          'matched': matched,
        }));
  } catch (e) {
    // 진짜 서버 오류만 500
    return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}));
  }
}

Future<Response> fetchMatchedDemandsForPropertyHandler(
    Request req, String propertyId) async {
  try {
    // 1. 해당 Property 조회
    Map<String, dynamic>? propertyMap;
    try {
      propertyMap =
          await propertiesCol.findOne({'_id': ObjectId.parse(propertyId)});
    } catch (e) {
      // ObjectId 파싱 실패 등
      return Response(200, body: jsonEncode([])); // 매칭 없음은 200
    }
    if (propertyMap == null) {
      // property가 없으면 매칭 없음 취급
      return Response(200, body: jsonEncode([]));
    }
    final property = PropertyModel.fromJson(propertyMap);
    // 2. 모든 Demand 조회
    final demandList = await propertyService.findDemand();
    final matched = <Map<String, dynamic>>[];
    for (final demandMap in demandList) {
      final demand = DemandModel.fromJson(demandMap);
      if (isMatchedDemandToProperty(demand, property)) {
        matched.add(demandMap);
      }
    }
    return Response(200, body: jsonEncode(matched));
  } catch (e) {
    // 진짜 서버 오류만 500
    return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}));
  }
}
