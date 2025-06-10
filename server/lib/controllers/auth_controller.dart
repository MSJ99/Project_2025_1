import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:http/http.dart' as http;
import '../utils/jwt.dart';
import '../services/auth_service.dart';

late AuthService userService; // main에서 주입

// 이메일 인증 코드 저장 (임시, 실제 서비스에서는 별도 저장소 필요)
final Map<String, Map<String, dynamic>> emailVerifications = {};

Future<Response> registerHandler(Request req) async {
  final body = await req.readAsString();
  final data = jsonDecode(body);
  final email = data['email'] as String?;

  if (email == null) {
    return Response(400, body: jsonEncode({'error': '이메일과 비밀번호를 입력하세요.'}));
  }

  final record = emailVerifications[email];
  if (record == null || record['verified'] != true) {
    return Response(400, body: jsonEncode({'error': '이메일 인증이 필요합니다.'}));
  }

  // 실제 회원가입 로직(DB 저장 등) 수행
  // ...

  // 인증 기록 삭제(보안상)
  emailVerifications.remove(email);

  return Response.ok(jsonEncode({'success': true}));
}

Future<Response> loginHandler(Request req) async {
  final data = jsonDecode(await req.readAsString());
  final id = data['id'];
  // 실제 DB에서 사용자 조회
  final user = await userService.findById(id);
  if (user == null) {
    return Response(401, body: jsonEncode({'error': '존재하지 않는 사용자입니다.'}));
  }
  final token = generateJwt({'id': user.id, 'email': user.email});
  return Response.ok(
    jsonEncode({
      'token': token,
      'userInfo': {'id': user.id, 'email': user.email},
    }),
  );
}

Response logoutHandler(Request req) {
  return Response.ok(jsonEncode({'success': true}));
}

Future<Response> sendVerificationHandler(Request req) async {
  final body = await req.readAsString();
  final data = jsonDecode(body);
  final email = data['email'] as String?;

  if (email == null || !email.contains('@')) {
    return Response(400, body: jsonEncode({'error': '유효한 이메일을 입력하세요.'}));
  }

  // 인증 코드 생성 및 저장
  final code =
      (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
  final expiresAt = DateTime.now().add(Duration(minutes: 5));
  emailVerifications[email] = {'code': code, 'expiresAt': expiresAt};
  return Response.ok(jsonEncode({'success': true}));
}

Future<Response> verifyCodeHandler(Request req) async {
  final body = await req.readAsString();
  final data = jsonDecode(body);
  final email = data['email'] as String?;
  final code = data['code'] as String?;

  if (email == null || code == null) {
    return Response(400, body: jsonEncode({'error': '이메일과 코드를 입력하세요.'}));
  }

  final record = emailVerifications[email];
  if (record == null || record['code'] != code) {
    return Response(400, body: jsonEncode({'error': '인증 코드가 올바르지 않습니다.'}));
  }
  if (DateTime.now().isAfter(record['expiresAt'])) {
    return Response(400, body: jsonEncode({'error': '인증 코드가 만료되었습니다.'}));
  }

  // 인증 성공: 인증 상태 저장 (간단 예시)
  record['verified'] = true;
  return Response.ok(jsonEncode({'success': true}));
}

Future<Response> googleLoginHandler(Request request) async {
  final body = await request.readAsString();
  final data = jsonDecode(body);
  final idToken = data['idToken'];

  // 1. Google에 idToken 검증 요청
  final googleRes = await http.get(
    Uri.parse('https://oauth2.googleapis.com/tokeninfo?id_token=$idToken'),
  );
  if (googleRes.statusCode != 200) {
    return Response.forbidden(jsonEncode({'error': 'Invalid Google token'}));
  }
  final googleUser = jsonDecode(googleRes.body);
  final googleId = googleUser['sub'];
  final email = googleUser['email'];

  // 2. 사용자 DB에 저장/조회 (UserService 사용)
  var user = await userService.findOrCreateUser(googleId, email);

  // 3. JWT 발급
  final jwt = generateJwt({'userId': user.id, 'email': user.email});

  // 4. 응답
  return Response.ok(jsonEncode({'token': jwt, 'user': user.toJson()}),
      headers: {'Content-Type': 'application/json'});
}

Future<Response> getMeHandler(Request request) async {
  // 1. JWT에서 사용자 정보 추출
  final authHeader = request.headers['authorization'];
  if (authHeader == null || !authHeader.startsWith('Bearer ')) {
    return Response.forbidden('No Authorization header');
  }
  final token = authHeader.substring(7);
  final payload = verifyJwt(token);
  if (payload == null) {
    return Response.forbidden('Invalid token');
  }
  // 2. 사용자 정보 반환
  return Response.ok(
      jsonEncode({'userId': payload['userId'], 'email': payload['email']}),
      headers: {'Content-Type': 'application/json'});
}
