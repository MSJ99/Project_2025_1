import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';

// MongoDB 연결
late Db db;
late DbCollection usersCol;
late DbCollection propertiesCol;

// JWT 시크릿 키
const jwtSecret = 'palbang_secret';

// JWT 인증 미들웨어
Middleware jwtMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final auth = request.headers['Authorization'];
      if (auth == null || !auth.startsWith('Bearer ')) {
        return Response.forbidden(jsonEncode({'error': '인증 필요'}));
      }
      final token = auth.substring(7);
      try {
        final jwt = JWT.verify(token, SecretKey(jwtSecret));
        // 인증된 사용자 정보 request context에 추가
        final updatedRequest = request.change(context: {'user': jwt.payload});
        return await innerHandler(updatedRequest);
      } catch (e) {
        return Response.forbidden(jsonEncode({'error': '유효하지 않은 토큰'}));
      }
    };
  };
}

// 회원가입
Future<Response> registerHandler(Request req) async {
  final data = jsonDecode(await req.readAsString());
  final id = data['id'];
  final password = data['password'];
  final exist = await usersCol.findOne({'id': id});
  if (exist != null) {
    return Response(400, body: jsonEncode({'error': '이미 존재하는 ID입니다.'}));
  }
  await usersCol.insert({'id': id, 'password': password});
  return Response.ok(jsonEncode({'userId': id}));
}

// 로그인
Future<Response> loginHandler(Request req) async {
  final data = jsonDecode(await req.readAsString());
  final id = data['id'];
  final password = data['password'];
  final user = await usersCol.findOne({'id': id, 'password': password});
  if (user == null) {
    return Response(401, body: jsonEncode({'error': 'ID 또는 비밀번호가 올바르지 않습니다.'}));
  }
  final jwt = JWT({'id': id});
  final token = jwt.sign(SecretKey(jwtSecret));
  return Response.ok(
    jsonEncode({
      'token': token,
      'userInfo': {'id': id},
    }),
  );
}

// 매물 등록
Future<Response> addPropertyHandler(Request req) async {
  final contentType = req.headers['content-type'];
  if (contentType == null || !contentType.contains('multipart/form-data')) {
    return Response(400, body: jsonEncode({'error': 'multipart/form-data 필요'}));
  }

  final boundary = contentType.split('boundary=')[1];
  final transformer = MimeMultipartTransformer(boundary);
  final bodyStream = req.read();
  final parts = await transformer.bind(bodyStream).toList();

  Map<String, dynamic> propertyData = {};
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
      final bytesList = await part.toList(); // List<List<int>>
      final bytes = bytesList.expand((e) => e).toList(); // List<int>
      await file.writeAsBytes(bytes);
      imageUrl = filePath;
    } else if (name != null) {
      final value = await utf8.decoder.bind(part).join();
      propertyData[name] = value;
    }
  }
  if (imageUrl != null) propertyData['image'] = imageUrl;
  final result = await propertiesCol.insert(propertyData);
  propertyData['_id'] = result['insertedId'];
  return Response.ok(jsonEncode(propertyData));
}

// 매물 리스트
Future<Response> listPropertiesHandler(Request req) async {
  final list = await propertiesCol.find().toList();
  return Response.ok(jsonEncode(list));
}

// 매물 상세정보
Future<Response> getPropertyHandler(Request req, String id) async {
  final objId = ObjectId.parse(id);
  final property = await propertiesCol.findOne({'_id': objId});
  if (property == null) {
    return Response(404, body: jsonEncode({'error': '매물을 찾을 수 없습니다.'}));
  }
  return Response.ok(jsonEncode(property));
}

// 매물 수정
Future<Response> editPropertyHandler(Request req, String id) async {
  final objId = ObjectId.parse(id);
  final property = await propertiesCol.findOne({'_id': objId});
  if (property == null) {
    return Response(404, body: jsonEncode({'error': '매물을 찾을 수 없습니다.'}));
  }
  final body = await req.readAsString();
  final data = jsonDecode(body);
  await propertiesCol.update({'_id': objId}, data);
  return Response.ok(jsonEncode(data));
}

// 매물 삭제
Future<Response> deletePropertyHandler(Request req, String id) async {
  final objId = ObjectId.parse(id);
  final property = await propertiesCol.findOne({'_id': objId});
  if (property == null) {
    return Response(404, body: jsonEncode({'error': '매물을 찾을 수 없습니다.'}));
  }
  await propertiesCol.remove({'_id': objId});
  return Response.ok(jsonEncode({'success': true}));
}

// 즐겨찾기 토글
Future<Response> toggleFavoriteHandler(Request req, String id) async {
  final objId = ObjectId.parse(id);
  final property = await propertiesCol.findOne({'_id': objId});
  if (property == null) {
    return Response(404, body: jsonEncode({'error': '매물을 찾을 수 없습니다.'}));
  }
  final isFavorite = !(property['isFavorite'] ?? false);
  await propertiesCol.update({
    '_id': objId
  }, {
    r'$set': {'isFavorite': isFavorite}
  });
  return Response.ok(jsonEncode({'isFavorite': isFavorite}));
}

// 로그아웃 (현재 구현 안됨)
Response logoutHandler(Request req) {
  return Response.ok(jsonEncode({'success': true}));
}

Future<void> startServer() async {
  db = await Db.create('mongodb://localhost:27017/palbang');
  await db.open();
  usersCol = db.collection('users');
  propertiesCol = db.collection('properties');

  final router = Router()
    ..post('/api/auth/register', registerHandler)
    ..post('/api/auth/login', loginHandler)
    ..post('/api/auth/logout', logoutHandler)
    ..post('/api/properties', addPropertyHandler)
    ..get('/api/properties', listPropertiesHandler)
    ..get('/api/properties/<id>', getPropertyHandler)
    ..put('/api/properties/<id>', editPropertyHandler)
    ..delete('/api/properties/<id>', deletePropertyHandler)
    ..post('/api/properties/<id>/favorite', toggleFavoriteHandler);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router);

  final server = await io.serve(handler, 'localhost', 8080);
  print('서버가 http://${server.address.host}:${server.port} 에서 실행 중입니다.');
}
