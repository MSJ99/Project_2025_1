import '../datasources/match_api.dart';
import '../models/demand.dart';
import '../models/property.dart';

class MatchRepository {
  final MatchApi api;
  MatchRepository(this.api);

  // 매칭된 매물 정보와 개수 반환
  Future<Map<String, dynamic>> fetchMatchedPropertiesForDemand(
    String demandId,
  ) => api.fetchMatchedPropertiesForDemand(demandId);

  // 매칭된 요구사항 정보와 개수 반환
  Future<Map<String, dynamic>> fetchMatchedDemandsForProperty(
    String propertyId,
  ) => api.fetchMatchedDemandsForProperty(propertyId);
}
