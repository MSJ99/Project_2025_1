import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

const jwtSecret = 'palbang_secret';

String generateJwt(Map<String, dynamic> payload) {
  final jwt = JWT(payload);
  return jwt.sign(SecretKey(jwtSecret));
}

// JWT를 검증하고 payload(Map)를 반환, 실패 시 null 반환
Map<String, dynamic>? verifyJwt(String token) {
  try {
    final jwt = JWT.verify(token, SecretKey(jwtSecret));
    return jwt.payload as Map<String, dynamic>;
  } catch (e) {
    // 유효하지 않은 토큰
    return null;
  }
}
