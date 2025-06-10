import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignInScreen extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  SignInScreen({Key? key}) : super(key: key);

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return; // 로그인 취소
      final auth = await account.authentication;
      final idToken = auth.idToken;

      // 서버에 idToken 전송
      final backendIp = dotenv.env['BACKEND_IP'] ?? 'localhost';
      final backendPort = dotenv.env['BACKEND_PORT'] ?? '8080';
      final response = await http.post(
        Uri.parse('http://$backendIp:$backendPort/api/auth/google-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jwt = data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', jwt);
        await fetchMyInfo();
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('서버 인증 실패')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google 로그인 실패: $e')));
    }
  }

  Future<void> fetchMyInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt');
    if (jwt == null) {
      print('로그인 필요');
      return;
    }
    final backendIp = dotenv.env['BACKEND_IP'] ?? 'localhost';
    final backendPort = dotenv.env['BACKEND_PORT'] ?? '8080';
    final response = await http.get(
      Uri.parse('http://$backendIp:$backendPort/api/auth/user/me'),
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      print('내 정보: \\${response.body}');
    } else {
      print('인증 실패 또는 오류: \\${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: () => _handleGoogleSignIn(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_circle, size: 24, color: Colors.grey),
                const SizedBox(width: 16),
                const Text(
                  'Continue with Google',
                  style: TextStyle(
                    color: Color(0x8A000000),
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
