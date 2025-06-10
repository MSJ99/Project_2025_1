import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/demand.dart';

class DemandApi {
  final String backendIp = dotenv.env['BACKEND_IP'] ?? 'localhost';
  final String backendPort = dotenv.env['BACKEND_PORT'] ?? '8080';

  Future<List<Demand>> fetchDemands() async {
    final url = Uri.parse('http://$backendIp:$backendPort/api/demands/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Demand.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load demands');
    }
  }

  Future<bool> addDemand(Demand demand) async {
    final url = Uri.parse('http://$backendIp:$backendPort/api/demands/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(demand.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> updateDemand(String id, Demand demand) async {
    final url = Uri.parse('http://$backendIp:$backendPort/api/demands/$id');
    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(demand.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteDemand(String id) async {
    final url = Uri.parse('http://$backendIp:$backendPort/api/demands/$id');
    final response = await http.delete(url);
    return response.statusCode == 200;
  }
}
