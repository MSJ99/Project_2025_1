import 'package:test/test.dart';
import 'package:shelf/shelf.dart';
import 'package:palbang_server/server.dart';
import 'dart:convert';

void main() {
  group('Auth Handlers', () {
    setUp(() async {
      // 테스트 전 usersCol 초기화 (실제 환경에서는 mock DB 또는 별도 테스트 DB 권장)
      await usersCol.drop();
    });

    test('회원가입 성공', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/api/auth/register'),
        body: jsonEncode({'id': 'testuser', 'password': '1234'}),
        headers: {'content-type': 'application/json'},
      );
      final response = await registerHandler(request);
      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      expect(jsonDecode(body)['userId'], equals('testuser'));
    });

    test('중복 회원가입 실패', () async {
      await usersCol.insert({'id': 'testuser', 'password': '1234'});
      final request = Request(
        'POST',
        Uri.parse('http://localhost/api/auth/register'),
        body: jsonEncode({'id': 'testuser', 'password': '1234'}),
        headers: {'content-type': 'application/json'},
      );
      final response = await registerHandler(request);
      expect(response.statusCode, equals(400));
    });

    test('로그인 성공', () async {
      await usersCol.insert({'id': 'testuser', 'password': '1234'});
      final request = Request(
        'POST',
        Uri.parse('http://localhost/api/auth/login'),
        body: jsonEncode({'id': 'testuser', 'password': '1234'}),
        headers: {'content-type': 'application/json'},
      );
      final response = await loginHandler(request);
      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      expect(jsonDecode(body)['userInfo']['id'], equals('testuser'));
    });

    test('로그인 실패', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/api/auth/login'),
        body: jsonEncode({'id': 'notexist', 'password': 'wrong'}),
        headers: {'content-type': 'application/json'},
      );
      final response = await loginHandler(request);
      expect(response.statusCode, equals(401));
    });
  });
}
