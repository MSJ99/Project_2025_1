import 'package:flutter/material.dart';
import '../data/models/demand.dart';
import '../data/repositories/demand_repository.dart';
import '../data/repositories/match_repository.dart';
import 'package:image_picker/image_picker.dart';

class DemandViewModel extends ChangeNotifier {
  final DemandRepository repository;
  final MatchRepository matchRepository;
  DemandViewModel(this.repository, this.matchRepository);
  List<Demand> _demands = [];
  bool _isLoading = false;
  Map<String, int> matchedPropertyCountByDemandId = {};

  List<Demand> get demands => _demands;
  bool get isLoading => _isLoading;

  Future<void> fetchDemands() async {
    _isLoading = true;
    notifyListeners();
    _demands = await repository.fetchDemands();
    for (final d in _demands) {
      print(
        '[DemandViewModel] fetchDemands: demand.id=${d.id}, customerName=${d.customerName}',
      );
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchDemandsAndMatches(MatchRepository matchRepo) async {
    _isLoading = true;
    notifyListeners();
    _demands = await repository.fetchDemands();
    for (final d in _demands) {
      print(
        '[DemandViewModel] fetchDemandsAndMatches: demand.id=${d.id}, customerName=${d.customerName}',
      );
    }
    matchedPropertyCountByDemandId.clear();
    for (final demand in _demands) {
      if (demand.id != null) {
        final result = await matchRepo.fetchMatchedPropertiesForDemand(
          demand.id!,
        );
        matchedPropertyCountByDemandId[demand.id!] = result['count'] ?? 0;
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addDemand(Demand demand) async {
    await repository.addDemand(demand);
    await fetchDemands();
  }

  Future<void> updateDemand(String id, Demand demand) async {
    await repository.updateDemand(id, demand);
    await fetchDemands();
  }

  Future<void> deleteDemand(String id) async {
    await repository.deleteDemand(id);
    await fetchDemands();
  }
}
