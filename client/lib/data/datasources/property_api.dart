import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/property.dart';

class PropertyApi {
  final String backendIp = dotenv.env['BACKEND_IP'] ?? 'localhost';
  final String backendPort = dotenv.env['BACKEND_PORT'] ?? '8080';

  Future<List<Property>> fetchProperties() async {
    final url = Uri.parse('http://$backendIp:$backendPort/api/properties/');
    final response = await http.get(url);
    print('[PropertyApi] response.body: ' + response.body);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final list =
          data
              .map((item) {
                try {
                  return Property.fromJson(item);
                } catch (e) {
                  print(
                    '[PropertyApi] Property.fromJson error: $e, item: $item',
                  );
                  return null;
                }
              })
              .where((e) => e != null)
              .cast<Property>()
              .toList();
      print('[PropertyApi] parsed property count: ' + list.length.toString());
      return list;
    } else {
      throw Exception('Failed to load properties');
    }
  }

  Future<bool> addProperty(Property property, String? imagePath) async {
    final url = Uri.parse('http://$backendIp:$backendPort/api/properties/');
    var request = http.MultipartRequest('POST', url);
    request.fields['address'] = property.address;
    request.fields['tradeType'] = property.tradeType;
    request.fields['floor'] = property.floor.toString();
    request.fields['area'] = property.area.toString();
    request.fields['price'] = property.price.toString();
    request.fields['options'] = property.options.join(',');
    request.fields['contact'] = property.contact;
    if (property.monthlyRent != null) {
      request.fields['monthlyRent'] = property.monthlyRent.toString();
    }
    request.fields['roomCount'] = property.roomCount.toString();
    request.fields['propertyType'] = property.propertyType;
    request.fields['moveInDate'] = property.moveInDate?.toString() ?? '';
    if (imagePath != null && imagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }
    final response = await request.send();
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> updateProperty(
    String id,
    Property property,
    String? imagePath,
  ) async {
    final url = Uri.parse('http://$backendIp:$backendPort/api/properties/$id');
    var request = http.MultipartRequest('PATCH', url);
    request.fields['address'] = property.address;
    request.fields['tradeType'] = property.tradeType;
    request.fields['floor'] = property.floor.toString();
    request.fields['area'] = property.area.toString();
    request.fields['price'] = property.price.toString();
    request.fields['options'] = property.options.join(',');
    request.fields['contact'] = property.contact;
    if (property.monthlyRent != null) {
      request.fields['monthlyRent'] = property.monthlyRent.toString();
    }
    request.fields['roomCount'] = property.roomCount.toString();
    request.fields['propertyType'] = property.propertyType;
    request.fields['moveInDate'] = property.moveInDate?.toString() ?? '';
    if (imagePath != null && imagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }
    final response = await request.send();
    return response.statusCode == 200;
  }
}
