import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:mime/mime.dart';

Future<Response> uploadsHandler(Request request, String file) async {
  print('[uploads] GET /uploads/$file');
  final filePath = 'uploads/$file';
  final fileObj = File(filePath);
  if (await fileObj.exists()) {
    final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';
    return Response.ok(fileObj.openRead(), headers: {'Content-Type': mimeType});
  } else {
    print('[uploads] 404 Not Found: $filePath');
    return Response.notFound('File not found');
  }
}
