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
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:dotenv/dotenv.dart';
import 'routes/auth_routes.dart';
import 'routes/property_routes.dart';
import 'routes/demand_routes.dart';
import 'utils/db.dart';
import 'controllers/auth_controller.dart';
import 'services/auth_service.dart';
import 'repositories/user_repository.dart';
import 'package:shelf_static/shelf_static.dart';
import 'controllers/static_controller.dart';
import 'routes/match_routes.dart';

// JWT 시크릿 키
const jwtSecret = 'palbang_secret';

// 이메일 인증 코드 저장
final Map<String, Map<String, dynamic>> emailVerifications = {};

// dotenv 객체 생성
final dotenv = DotEnv();

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
  final body = await req.readAsString();
  final data = jsonDecode(body);
  final email = data['email'] as String?;
  final password = data['password'] as String?;

  if (email == null || password == null) {
    return Response(400, body: jsonEncode({'error': '이메일과 비밀번호를 입력하세요.'}));
  }

  final record = emailVerifications[email];
  if (record == null || record['verified'] != true) {
    return Response(400, body: jsonEncode({'error': '이메일 인증이 필요합니다.'}));
  }

  // 실제 회원가입 로직(DB 저장 등) 수행
  // ... 기존 회원가입 코드 ...

  // 인증 기록 삭제(보안상)
  emailVerifications.remove(email);

  return Response.ok(jsonEncode({'success': true}));
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
  propertyData.remove('id');
  final result = await propertiesCol.insert(propertyData);
  propertyData['_id'] = result['insertedId'];
  // _id를 id로 변환해서 응답에 포함
  propertyData['id'] = propertyData['_id'].toString();
  propertyData.remove('_id');
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

// 인증 코드 발송 API
Future<Response> sendVerificationHandler(Request req) async {
  final body = await req.readAsString();
  final data = jsonDecode(body);
  final email = data['email'] as String?;

  if (email == null || !email.contains('@')) {
    return Response(400, body: jsonEncode({'error': '유효한 이메일을 입력하세요.'}));
  }

  // 인증 코드 생성
  final code =
      (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
  final expiresAt = DateTime.now().add(Duration(minutes: 5));
  emailVerifications[email] = {'code': code, 'expiresAt': expiresAt};

  // 메일 발송 설정
  final smtpServer = SmtpServer(
    'smtp.naver.com',
    username: dotenv['EMAIL_USER'],
    password: dotenv['EMAIL_PASS'],
    port: 465,
    ssl: true,
  );

  final message = Message()
    ..from = Address('your_email@naver.com', '팔방')
    ..recipients.add(email)
    ..subject = '[팔방] 이메일 인증 코드'
    ..text = '인증 코드: $code\n5분 이내에 입력해주세요.';

  try {
    await send(message, smtpServer);
    return Response.ok(jsonEncode({'success': true}));
  } catch (e) {
    return Response(500, body: jsonEncode({'error': '이메일 발송 실패: $e'}));
  }
}

Future<HttpServer> startServer(
    {String address = '0.0.0.0', int port = 8080}) async {
  final dotenv = DotEnv()..load();
  await connectDb();

  // AuthService 인스턴스 생성 및 주입
  userService = AuthService(UserRepository(db));

  final staticHandler =
      createStaticHandler('uploads', serveFilesOutsidePath: true);

  final router = Router()
    ..get('/uploads/<file|.*>', uploadsHandler)
    ..mount('/api/properties/', propertyRoutes)
    ..mount('/api/demands/', demandRoutes)
    ..mount('/api/auth/', authRoutes)
    ..mount('/api/match/', matchRoutes);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router);

  final server = await io.serve(handler, address, port);
  print('서버가 http://$address:$port 에서 실행 중입니다.');

  // 실제 사용 가능한 IPv4 주소 목록 출력
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
    includeLoopback: false,
  );
  final ipList = interfaces
      .expand((interface) => interface.addresses)
      .map((addr) => addr.address)
      .toList();
  if (ipList.isNotEmpty) {
    for (final ip in ipList) {
      print('로컬 네트워크에서 접속: http://$ip:$port');
    }
  }
  return server;
}

void main() async {
  await startServer();
}
