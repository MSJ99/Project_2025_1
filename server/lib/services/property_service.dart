// 매물 관련 서비스 로직 (추후 구현)
import '../repositories/property_repository.dart';
import '../repositories/demand_repository.dart';
import '../models/property_model.dart';
import '../models/demand_model.dart';
import '../utils/match.dart';

class PropertyService {
  final PropertyRepository propertyRepository;
  final DemandRepository demandRepository;
  PropertyService(this.propertyRepository, this.demandRepository);

  Future<Map<String, dynamic>> addProperty(Map<String, dynamic> data) async {
    final result = await propertyRepository.insert(data);
    return result;
  }

  Future<List<Map<String, dynamic>>> listProperties() async {
    return await propertyRepository.find();
  }

  Future<Map<String, dynamic>?> getProperty(String id) async {
    return await propertyRepository.findOne(id);
  }

  Future<Map<String, dynamic>?> updateProperty(
      String id, Map<String, dynamic> data) async {
    return await propertyRepository.update(id, data);
  }

  Future<bool> deleteProperty(String id) async {
    return await propertyRepository.delete(id);
  }

  Future<Map<String, dynamic>> matchPropertiesForDemand(String demandId) async {
    final demand = await demandRepository.findOne(demandId);
    if (demand == null) return {'count': 0, 'matched': []};
    final demandModel = DemandModel.fromJson(demand);
    final propertyList = await propertyRepository.find();
    final matched = <Map<String, dynamic>>[];
    for (final propMap in propertyList) {
      final property = PropertyModel.fromJson(propMap);
      // isMatchedDemandToProperty는 utils/match.dart에 있다고 가정
      if (isMatchedDemandToProperty(demandModel, property)) {
        matched.add(propMap);
      }
    }
    return {'count': matched.length, 'matched': matched};
  }

  // Controller에서 사용할 수 있도록 추가 메서드 제공
  Future<Map<String, dynamic>?> findOneDemand(String id) async {
    return await demandRepository.findOne(id);
  }

  Future<List<Map<String, dynamic>>> find() async {
    return await listProperties();
  }

  Future<List<Map<String, dynamic>>> findDemand() async {
    return await demandRepository.find();
  }

  Future<dynamic> editProperty(String id, Map<String, dynamic> data) async {
    return await updateProperty(id, data);
  }
}
