import '../lib/main.dart' as app;
import 'dart:io';

void main(List<String> args) async {
  await app.startServer(address: '0.0.0.0', port: 8080);
  print('현재 작업 디렉토리: ${Directory.current.path}');
}
