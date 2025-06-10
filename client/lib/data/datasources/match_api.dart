import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/demand.dart';
import '../models/property.dart';

class MatchApi {
  final String backendIp = dotenv.env['BACKEND_IP'] ?? 'localhost';
  final String backendPort = dotenv.env['BACKEND_PORT'] ?? '8080';

  // 요구사항에 맞는 매물 리스트
  Future<Map<String, dynamic>> fetchMatchedPropertiesForDemand(
    String demandId,
  ) async {
    final url = Uri.parse(
      'http://$backendIp:$backendPort/api/match/demand/$demandId',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // 서버에서 { count, matched } 구조로 반환됨
      return {
        'count': data['count'] ?? 0,
        'matched':
            (data['matched'] as List<dynamic>?)
                ?.map((item) => Property.fromJson(item))
                .toList() ??
            [],
      };
    } else {
      // 매칭 없음 또는 오류 시 빈 값 반환
      return {'count': 0, 'matched': <Property>[]};
    }
  }

  // (확장) 매물에 맞는 요구사항 리스트
  Future<Map<String, dynamic>> fetchMatchedDemandsForProperty(
    String propertyId,
  ) async {
    final url = Uri.parse(
      'http://$backendIp:$backendPort/api/match/property/$propertyId',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // 서버에서 { count, matched } 구조로 반환됨
      return {
        'count': data['count'] ?? 0,
        'matched':
            (data['matched'] as List<dynamic>?)
                ?.map((item) => Demand.fromJson(item))
                .toList() ??
            [],
      };
    } else {
      // 매칭 없음 또는 오류 시 빈 값 반환
      return {'count': 0, 'matched': <Demand>[]};
    }
  }
}
