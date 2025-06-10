import '../datasources/demand_api.dart';
import '../models/demand.dart';
import 'package:image_picker/image_picker.dart';

class DemandRepository {
  final DemandApi api;
  DemandRepository(this.api);

  Future<List<Demand>> fetchDemands() => api.fetchDemands();
  Future<bool> addDemand(Demand demand) => api.addDemand(demand);
  Future<bool> updateDemand(String id, Demand demand) =>
      api.updateDemand(id, demand);
  Future<bool> deleteDemand(String id) => api.deleteDemand(id);
}
